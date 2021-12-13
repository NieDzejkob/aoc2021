import sys

points = set()

def fold_y(ps, Y):
    return {(x, y) if y <= Y else (x, Y - (y - Y)) for x, y in ps}

def fold_x(ps, X):
    return {(x, y) if x <= X else (X - (x - X), y) for x, y in ps}

for line in sys.stdin:
    line = line.strip()
    if line:
        x, y = map(int, line.split(','))
        points.add((x, y))
    else:
        break

for line in sys.stdin:
    assert line.startswith('fold')
    var, coord = line.split()[-1].split('=')
    if var == 'y':
        points = fold_y(points, int(coord))
    else:
        points = fold_x(points, int(coord))
    print(len(points))

Y = max(y for x, y in points)
X = max(x for x, y in points)

for y in range(Y+1):
    print(''.join('#' if (x, y) in points else ' ' for x in range(X+1)))
