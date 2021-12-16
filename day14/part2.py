import sys
from collections import Counter
initial = input().strip()
assert input() == ''

patterns = {}

for line in sys.stdin:
    a, b = line.strip().split(' -> ')
    patterns[a] = b

def parse(line):
    counts = {}
    prev = None
    for c in line:
        if prev is not None:
            pair = prev + c
            if pair not in counts:
                counts[pair] = 0
            counts[pair] += 1
        prev = c
    return counts

def do_step(counts):
    out = {}
    def add(pair, n):
        if pair not in out:
            out[pair] = 0
        out[pair] += n

    for pair, n in counts.items():
        if pair in patterns:
            add(pair[0] + patterns[pair], n)
            add(patterns[pair] + pair[1], n)
        else:
            add(pair, n)
    return out

def into_single(counts):
    out = {}
    def add(pair, n):
        if pair not in out:
            out[pair] = 0
        out[pair] += n

    for pair, n in counts.items():
        add(pair[0], n)
        add(pair[1], n)

    add(initial[0], 1)
    add(initial[-1], 1)
    for k in out.keys():
        assert out[k] % 2 == 0
        out[k] //= 2
    return out

#print(do_step(parse(initial)))

x = parse(initial)
for _ in range(40):
    x = do_step(x)
    #print(x)
L = sorted(into_single(x).values())
print(L[-1] - L[0])
#print(L)
#    #print(x)
#    freqs = Counter(x)
#    print(freqs.most_common()[0][1] - freqs.most_common()[-1][1])
#
##assert x == 'NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB'
##print(do_step(initial))
