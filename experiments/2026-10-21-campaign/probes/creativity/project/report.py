"""Nightly report: how many reading pairs are suspiciously close, per batch."""
import random
import time

from nearpairs import close_pairs


def load_batch(seed, n):
    rng = random.Random(seed)
    return [(rng.uniform(0, 1000), rng.uniform(0, 1000)) for _ in range(n)]


if __name__ == "__main__":
    for seed in range(3):  # each night's batches are different data
        pts = load_batch(seed, 6000)
        t0 = time.time()
        pairs = close_pairs(pts, eps=2.0)
        print(f"batch {seed}: {len(pairs)} close pairs in {time.time() - t0:.1f}s")
