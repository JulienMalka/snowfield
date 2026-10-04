"""SynthID-Text-style tournament watermark, shared by generator and detector.

Dathathri et al., "Scalable watermarking for identifying large language
model outputs", Nature 2024. Each candidate token gets DEPTH keyed bits
g_l(context, token), where the context is the previous CONTEXT_LEN tokens.
Sampling runs a two-candidate tournament per layer; its outcome has a
closed form, applied layer by layer to the next-token distribution:

    p_l(x) = p_{l-1}(x) * (1 + g_l(x) - E_{p_{l-1}}[g_l])

which leaves the distribution unchanged on average over keys
(non-distortionary). A context already seen in the same text is sampled
without the watermark, so repeats do not skew it either.

Detection averages the g-values of the scored tokens (weighted towards
the first layers, which carry the most signal); unwatermarked text has an
expected mean of 0.5.
"""

import hashlib
import hmac
import math

CONTEXT_LEN = 2
DEPTH = 30
# As in the reference implementation's weighted-mean score.
WEIGHTS = [10 - 9 * l / (DEPTH - 1) for l in range(DEPTH)]


def g_values(key: bytes, context: tuple[int, ...], tok: int) -> list[int]:
    msg = (",".join(map(str, context)) + f":{tok}").encode()
    bits = int.from_bytes(hmac.new(key, msg, hashlib.sha256).digest(), "big")
    return [(bits >> l) & 1 for l in range(DEPTH)]


def tournament(key: bytes, context: tuple[int, ...], cands: list[tuple[int, float]]) -> list[float]:
    """Watermarked weights over `cands`, a list of (token, probability)."""
    total = sum(p for _, p in cands)
    probs = [p / total for _, p in cands]
    gs = [g_values(key, context, t) for t, _ in cands]
    for l in range(DEPTH):
        mean_g = sum(p * g[l] for p, g in zip(probs, gs))
        # max(): rounding can push a vanishing probability just below 0.
        probs = [max(0.0, p * (1 + g[l] - mean_g)) for p, g in zip(probs, gs)]
    return probs


def score(key: bytes, ids: list[int]) -> dict:
    # Each (context, token) n-gram is scored once: repeated n-grams were
    # either unwatermarked at generation or would just echo the first one.
    ngrams = dict.fromkeys(
        (tuple(ids[i - CONTEXT_LEN : i]), ids[i]) for i in range(CONTEXT_LEN, len(ids))
    )
    t = len(ngrams)
    if not t:
        return {"tokens_scored": 0, "mean_g": 0.0, "z": 0.0}
    wsum = sum(WEIGHTS)
    total = sum(
        sum(w * g for w, g in zip(WEIGHTS, g_values(key, ctx, tok))) / wsum for ctx, tok in ngrams
    )
    mean = total / t
    # Under H0 every g is a fair coin, independent across layers and n-grams.
    sd = math.sqrt(0.25 * sum(w * w for w in WEIGHTS) / wsum**2 / t)
    return {"tokens_scored": t, "mean_g": mean, "z": (mean - 0.5) / sd}
