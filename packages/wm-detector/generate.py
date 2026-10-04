"""Generate a watermarked text one token at a time against the vLLM API.

Each step asks for the top-20 next-token logprobs, runs the SynthID-style
tournament over those 20 (see scheme.py) and samples. Prefix caching keeps
the per-step cost to roughly one decode.

Long runs checkpoint the generated ids to `<out>.state.json` and pick up
from there when restarted with the same arguments.
"""

import argparse
import json
import math
import os
import random
import sys
import time
import urllib.error
import urllib.request

from scheme import CONTEXT_LEN, score, tournament

EOS = 1
CHECKPOINT_EVERY = 50


def post(base, path, body, attempts=10):
    req = urllib.request.Request(
        base + path, json.dumps(body).encode(), {"content-type": "application/json"}
    )
    for attempt in range(attempts):
        try:
            with urllib.request.urlopen(req, timeout=120) as r:
                return json.load(r)
        except (urllib.error.URLError, TimeoutError, ConnectionError) as e:
            if attempt == attempts - 1:
                raise
            delay = min(60, 2**attempt)
            print(f"{path}: {e}; retrying in {delay}s", file=sys.stderr, flush=True)
            time.sleep(delay)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--base", default="http://100.100.45.44:8000")
    ap.add_argument("--model", default="deepseek-v4-flash")
    ap.add_argument("--key-file", required=True)
    ap.add_argument("--prompt", required=True)
    ap.add_argument("--min-tokens", type=int, default=0, help="never end before this many tokens")
    ap.add_argument("--max-tokens", type=int, default=1800)
    ap.add_argument("--out", required=True)
    args = ap.parse_args()

    key = open(args.key_file, "rb").read().strip()
    prompt_ids = post(
        args.base,
        "/tokenize",
        {
            "model": args.model,
            "messages": [{"role": "user", "content": args.prompt}],
            "add_generation_prompt": True,
            "chat_template_kwargs": {"thinking": False},
        },
    )["tokens"]

    state_path = args.out + ".state.json"
    out: list[int] = []
    if os.path.exists(state_path):
        state = json.load(open(state_path))
        assert state["prompt_ids"] == prompt_ids, "checkpoint is for another prompt"
        out = state["out"]
        print(f"resuming at token {len(out)}", file=sys.stderr, flush=True)

    def checkpoint():
        with open(state_path + ".tmp", "w") as f:
            json.dump({"prompt_ids": prompt_ids, "out": out}, f)
        os.replace(state_path + ".tmp", state_path)

    full = prompt_ids + out
    seen_contexts = {tuple(full[i - CONTEXT_LEN : i]) for i in range(len(prompt_ids), len(full))}
    coverage = []
    rng = random.SystemRandom()
    while len(out) < args.max_tokens:
        ids = prompt_ids + out
        resp = post(
            args.base,
            "/v1/completions",
            {
                "model": args.model,
                "prompt": ids,
                "max_tokens": 1,
                "logprobs": 20,
                "return_tokens_as_token_ids": True,
                "temperature": 1.0,
            },
        )
        top = resp["choices"][0]["logprobs"]["top_logprobs"][0]
        context = tuple(ids[-CONTEXT_LEN:])
        cands = [(int(k.removeprefix("token_id:")), math.exp(lp)) for k, lp in top.items()]
        coverage.append(sum(p for _, p in cands))
        if len(out) < args.min_tokens:
            cands = [(t, p) for t, p in cands if t != EOS]
        if context in seen_contexts:
            weights = [p for _, p in cands]
        else:
            seen_contexts.add(context)
            weights = tournament(key, context, cands)
        tok = rng.choices([t for t, _ in cands], weights)[0]
        if tok == EOS:
            break
        out.append(tok)
        if len(out) % CHECKPOINT_EVERY == 0:
            checkpoint()
            print(f"tokens {len(out)}", file=sys.stderr, flush=True)
    checkpoint()

    text = post(args.base, "/detokenize", {"model": args.model, "tokens": out})["prompt"]
    # Score as the detector will: re-tokenize the plain text.
    retok = post(args.base, "/tokenize", {"model": args.model, "prompt": text, "add_special_tokens": False})["tokens"]
    stats = {
        "generated_tokens": len(out),
        "words": len(text.split()),
        "mean_top20_coverage": sum(coverage) / len(coverage) if coverage else None,
        "score_generated_ids": score(key, out),
        "score_retokenized": score(key, retok),
    }
    with open(args.out, "w") as f:
        f.write(text)
    print(json.dumps(stats, indent=2))


if __name__ == "__main__":
    main()
