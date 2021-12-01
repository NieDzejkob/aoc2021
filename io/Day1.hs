import Verified.Day1

parseInput :: String -> [Verified.Day1.Int]
parseInput s = Int_of_integer <$> read <$> lines s

part2 = part1 . windows

runTest fname = do
  input <- parseInput <$> readFile fname
  return $ (integer_of_nat (part1 input), integer_of_nat (part2 input))

main = do
  print =<< runTest "input/day1-example.txt"
  print =<< runTest "input/day1.txt"
