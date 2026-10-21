"""Find pairs of sensor readings that sit close together in (x, y)."""


def close_pairs(points, eps):
    """Return index pairs (i, j), i < j, whose points lie within eps of each other."""
    out = []
    n = len(points)
    for i in range(n):
        xi, yi = points[i]
        for j in range(i + 1, n):
            xj, yj = points[j]
            if (xi - xj) ** 2 + (yi - yj) ** 2 <= eps * eps:
                out.append((i, j))
    return out
