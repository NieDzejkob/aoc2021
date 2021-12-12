import sys
grid = []
flashes = 0
for line in sys.stdin:
    grid.append(list(map(int, line.strip())))

def step():
    global flashes
    flashqueue = []
    flashed = set()
    for y in range(len(grid)):
        for x in range(len(grid[0])):
            grid[y][x] += 1
            if grid[y][x] > 9:
                flashqueue.append((y, x))
                flashed.add((y, x))
                flashes += 1
    while flashqueue:
        p = flashqueue.pop()
        for y in range(p[0]-1, p[0]+2):
            for x in range(p[1]-1, p[1]+2):
                if y in range(len(grid)) and x in range(len(grid[0])):
                    grid[y][x] += 1
                    if grid[y][x] > 9 and (y, x) not in flashed:
                        flashqueue.append((y, x))
                        flashed.add((y, x))
                        flashes += 1
    for y, x in flashed:
        grid[y][x] = 0
    return len(flashed) == len(grid) * len(grid[0])

for i in range(10000):
    if step():
        print(i)
        break
#    for line in grid:
#        print(''.join(map(str, line)))
#    print()

#print(flashes)
