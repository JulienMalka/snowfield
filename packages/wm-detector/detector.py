"""Watermark detector: POST text, get the tournament-watermark z-score back.

  POST /detect  {"text": "..."}  ->  {"watermarked": bool, "z": ..., ...}
  GET  /                         ->  a small form for humans
  GET  /essay.txt                ->  the watermarked essay (with --essay)

Tokenizes with the model's own tokenizer.json, so it runs without the
vLLM cluster.
"""

import argparse
import json
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

from tokenizers import Tokenizer

from scheme import score

Z_THRESHOLD = 4.0
MIN_TOKENS = 200
MAX_CHARS = 200_000

PAGE = """<!doctype html>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<title>Watermark detector</title>
<style>
  body { font: 16px/1.5 system-ui, sans-serif; max-width: 48rem; margin: 2rem auto; padding: 0 1rem; }
  textarea { width: 100%; height: 20rem; font: inherit; box-sizing: border-box; }
  pre { background: #f4f4f4; padding: 1rem; white-space: pre-wrap; }
</style>
<h1>Watermark detector</h1>
<p>The watermarked essay: <a href="/essay.txt">essay.txt</a>.</p>
<p>Paste a text. It is flagged as watermarked when z &ge; THRESHOLD (at least MIN_TOKENS tokens).</p>
<textarea id="t"></textarea>
<p><button id="b">Detect</button></p>
<pre id="o"></pre>
<script>
  document.getElementById("b").onclick = async () => {
    const r = await fetch("/detect", { method: "POST", headers: { "content-type": "application/json" },
      body: JSON.stringify({ text: document.getElementById("t").value }) });
    document.getElementById("o").textContent = JSON.stringify(await r.json(), null, 2);
  };
</script>
""".replace("THRESHOLD", str(Z_THRESHOLD)).replace("MIN_TOKENS", str(MIN_TOKENS))


def make_handler(key: bytes, tok: Tokenizer, essay: str | None):
    class Handler(BaseHTTPRequestHandler):
        def reply(self, code, body, ctype="application/json"):
            data = body.encode() if isinstance(body, str) else json.dumps(body).encode()
            self.send_response(code)
            self.send_header("content-type", ctype)
            self.send_header("content-length", str(len(data)))
            self.end_headers()
            self.wfile.write(data)

        def do_GET(self):
            if self.path == "/":
                self.reply(200, PAGE, "text/html; charset=utf-8")
            elif self.path == "/essay.txt" and essay is not None:
                self.reply(200, essay, "text/plain; charset=utf-8")
            else:
                self.reply(404, {"error": "not found"})

        def do_POST(self):
            if self.path != "/detect":
                return self.reply(404, {"error": "not found"})
            try:
                length = int(self.headers.get("content-length", 0))
                if length > 4 * MAX_CHARS:
                    return self.reply(413, {"error": "request too large"})
                text = json.loads(self.rfile.read(length))["text"]
                if not isinstance(text, str):
                    raise TypeError
            except (ValueError, KeyError, TypeError):
                return self.reply(400, {"error": 'expected JSON {"text": "..."}'})
            if len(text) > MAX_CHARS:
                return self.reply(413, {"error": f"text is {len(text)} characters, limit is {MAX_CHARS}"})

            ids = tok.encode(text, add_special_tokens=False).ids
            s = score(key, ids)
            enough = s["tokens_scored"] >= MIN_TOKENS
            self.reply(
                200,
                {
                    "watermarked": enough and s["z"] >= Z_THRESHOLD,
                    "z": round(s["z"], 2),
                    "z_threshold": Z_THRESHOLD,
                    "mean_g": round(s["mean_g"], 4),
                    "expected_mean_g_unwatermarked": 0.5,
                    "tokens_scored": s["tokens_scored"],
                    "min_tokens": MIN_TOKENS,
                    **({} if enough else {"note": "too short to judge"}),
                },
            )

    return Handler


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--key-file", required=True)
    ap.add_argument("--tokenizer", default="tokenizer.json")
    ap.add_argument("--essay", help="watermarked text to serve at /essay.txt")
    ap.add_argument("--host", default="127.0.0.1")
    ap.add_argument("--port", type=int, default=8765)
    args = ap.parse_args()

    key = open(args.key_file, "rb").read().strip()
    tok = Tokenizer.from_file(args.tokenizer)
    essay = open(args.essay).read() if args.essay else None
    server = ThreadingHTTPServer((args.host, args.port), make_handler(key, tok, essay))
    print(f"listening on http://{args.host}:{args.port}", flush=True)
    server.serve_forever()


if __name__ == "__main__":
    main()
