class Board:
    def __init__(self, numbers):
        self.numbers = numbers
        self.marked = [[False] * 5 for _ in range(5)]
        self.won = False

    def check_win(self):
        for r in self.marked:
            if all(r):
                return True
        for c in zip(*self.marked):
            if all(c):
                return True
        return False

    def handle_number(self, n):
        for i, row in enumerate(self.numbers):
            for j, col in enumerate(row):
                if col == n:
                    self.marked[i][j] = True
        self.won = self.check_win()
        return self.won

    def sum_unmarked(self):
        s = 0
        for n, m in zip(self.numbers, self.marked):
            for a, b in zip(n, m):
                if not b: s += a
        return s

def get_input():
    seq = list(map(int, input().split(',')))
    boards = []

    try:
        while True:
            assert input() == ''
            board = []
            for _ in range(5):
                board.append(list(map(int, input().split())))
            boards.append(Board(board))
    except EOFError:
        pass

    return seq, boards

seq, boards = get_input()

def winners():
    for n in seq:
        for i, board in enumerate(boards):
            if board.won: continue
            if board.handle_number(n):
                yield board.sum_unmarked() * n
w = list(winners())
print(w[0], w[-1])
