import sys
from functools import reduce
lines = [list(map(int, s.strip())) for s in sys.stdin]

def neighbours(r, c):
    for dr, dc in [(1, 0), (-1, 0), (0, 1), (0, -1)]:
        rr = r + dr
        cc = c + dc
        if 0 <= rr < len(lines) and 0 <= cc < len(lines[0]):
            yield (rr, cc)

def at(p):
    y, x = p
    return lines[y][x]

def basin(p):
    visited = {p}
    queue = [p]
    while queue:
        p = queue.pop()
        for q in neighbours(*p):
            if at(p) < at(q) < 9 and q not in visited:
                visited.add(q)
                queue.append(q)
    return len(visited)

part1 = 0
basins = []
for i, r in enumerate(lines):
    for j, c in enumerate(r):
        if all(c < at(p) for p in neighbours(i, j)):
            part1 += 1 + c
            basins.append(basin((i, j)))
print(part1)
basins.sort()
print(reduce(int.__mul__, basins[-3:]))
