import Data.Functor

type Position = (Integer, Integer)
type Move = (String, Integer)

type Position' = (Integer, Integer, Integer)

go :: Move -> Position -> Position
go ("forward", n) (x, y) = (x + n, y)
go ("down", n) (x, y) = (x, y + n)
go ("up", n) (x, y) = (x, y - n)

go' :: Move -> Position' -> Position'
go' ("forward", n) (x, y, v) = (x + n, y + n * v, v)
go' ("down", n) (x, y, v) = (x, y, v + n)
go' ("up", n) (x, y, v) = (x, y, v - n)

parseLine :: String -> Move
parseLine s =
  let [dir, dist] = words s in
  (dir, read dist)

readInput :: String -> IO [Move]
readInput fname = do
  input <- readFile fname
  return $ parseLine <$> lines input

part1 :: [Move] -> Integer
part1 = (uncurry (*)) . foldl (flip go) (0, 0)

part2 :: [Move] -> Integer
part2 = (\(x, y, v) -> x * y) . foldl (flip go') (0, 0, 0)

main = do
  readInput "input-example.txt" <&> part1 >>= print
  readInput "input.txt" <&> part1 >>= print

  readInput "input-example.txt" <&> part2 >>= print
  readInput "input.txt" <&> part2 >>= print
