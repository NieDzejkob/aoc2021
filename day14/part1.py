import sys
from collections import Counter
initial = input().strip()
assert input() == ''

patterns = {}

for line in sys.stdin:
    a, b = line.strip().split(' -> ')
    patterns[a] = b

def do_step(line):
    prev = None
    out = ''
    for c in line:
        if prev is not None:
            pair = prev + c
            if pair in patterns:
                out += patterns[pair]
        out += c
        prev = c
    return out

x = initial
for _ in range(2):
    x = do_step(x)
    print(x)
freqs = Counter(x)
print(freqs)
#print(freqs.most_common()[0][1] - freqs.most_common()[-1][1])

#assert x == 'NBBNBNBBCCNBCNCCNBBNBBNBBBNBBNBBCBHCBHHNHCBBCBHCB'
#print(do_step(initial))
