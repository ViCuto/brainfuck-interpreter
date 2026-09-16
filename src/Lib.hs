{-# OPTIONS_GHC -Wno-unrecognised-pragmas #-}
{-# HLINT ignore "Use bimap" #-}
module Lib where

import System.IO
import Text.Read (readMaybe)


main :: IO ()
main = do
    putStrLn " ________________________"
    putStrLn "|                        |"
    putStrLn "| Brainfuck Interpetator |"
    putStrLn "|________________________|"
    menu

menu :: IO ()
menu = do
    putStrLn "Choose an option (enter a number 1-5):"
    putStrLn "1. brainfuck"
    putStrLn "2. concat"
    putStrLn "3. parallel"
    putStrLn "4. alternate"
    putStrLn "5. exit"
    cmd <- getLine
    case cmd of
        "1" -> runBrainfuck >> menu
        "2" -> concatProgramsMenu >> menu
        "3" -> parallelProgramsMenu >> menu
        "4" -> alternateProgramsMenu >> menu
        "5" -> putStrLn "Exiting..."
        _ -> putStrLn "Invalid option, try again." >> menu

parseInput :: String -> Maybe [Int]
parseInput input = traverse readMaybe (words input)

runBrainfuck :: IO ()
runBrainfuck = do
    putStrLn "Enter file name:"
    fileName <- getLine
    putStrLn "Enter Ints (space-separated numbers):"
    inputNumbers <- getLine
    case parseInput inputNumbers of
      Just numbers -> do
          result <- brainfuck fileName numbers
          putStrLn $ "Output: " ++ show result
      Nothing -> putStrLn "Error: Invalid input. Please enter valid integers."

handleProgramsMenu :: (FilePath -> FilePath -> [Int] -> IO [Int]) -> IO ()
handleProgramsMenu action = do
    putStrLn "Enter the first file name:"
    pFile <- getLine
    putStrLn "Enter the second file name:"
    qFile <- getLine
    putStrLn "Enter Ints (space-separated numbers):"
    inputNumbers <- getLine
    case parseInput inputNumbers of
        Just numbers -> do
            result <- action pFile qFile numbers
            putStrLn $ "Output: " ++ show result
        Nothing -> putStrLn "Error: Invalid input. Please enter valid integers."

concatProgramsMenu :: IO ()
concatProgramsMenu = handleProgramsMenu concatPrograms

parallelProgramsMenu :: IO ()
parallelProgramsMenu = handleProgramsMenu parallelPrograms

alternateProgramsMenu :: IO ()
alternateProgramsMenu = handleProgramsMenu alternatePrograms

checkBrackets :: String -> Bool
checkBrackets str = helper str 0
  where
    helper :: String -> Int -> Bool
    helper [] 0 = True
    helper [] _ = False
    helper (x:xs) n
      | x == '[' = helper xs (n + 1)
      | x == ']' = (n > 0) && helper xs (n - 1)
      | otherwise = helper xs n

type Tape = ([Int], Int, [Int])

initTape :: Int -> Tape
initTape size = ([], 0, replicate (size - 1)  0)

moveRight :: Tape -> Tape
moveRight (_, _, []) = error "Error: Reached the end of the tape on the right."
moveRight (ys, z, x:xs) = (z:ys, x, xs)

moveLeft :: Tape -> Tape
moveLeft ([], _, _) = error "Error: Reached the start of the tape on the left."
moveLeft (x:xs, z, ys) = (xs, x, z:ys)

increment :: Tape -> Tape
increment (xs, z, ys) = (xs, z + 1, ys)

decrement :: Tape -> Tape
decrement (xs, z, ys) = (xs, z - 1, ys)

getValue :: Tape -> Int
getValue (_, x, _) = x

setValue :: Int -> Tape -> Tape
setValue z (xs, _, ys) = (xs, z, ys)

data BFCommand
  = MoveRight
  | MoveLeft
  | Increment
  | Decrement
  | Output
  | Input
  | Loop [BFCommand]
  deriving (Show, Eq)

parseBF :: String -> [BFCommand]
parseBF code = helper 0 (length code) []
  where
    helper ip end stack
      | ip >= end = reverse stack 
      | otherwise = case code !! ip of
          '>' -> helper (ip + 1) end (MoveRight : stack)
          '<' -> helper (ip + 1) end (MoveLeft : stack)
          '+' -> helper (ip + 1) end (Increment : stack)
          '-' -> helper (ip + 1) end (Decrement : stack)
          '.' -> helper (ip + 1) end (Output : stack)
          ',' -> helper (ip + 1) end (Input : stack)
          '[' -> let jumpPos = jumpForward code ip
                     loopCommands = helper (ip + 1) (jumpPos - 1) []
                 in helper jumpPos end (Loop loopCommands : stack)
          ']' -> error "Error: Unmatched brackets. No opening '['"
          _ -> helper (ip + 1) end stack

jumpForward :: String -> Int -> Int
jumpForward code ip = helper (ip + 1) 1
  where
    helper i 0 = i
    helper i n
      | i >= length code = error "Error: Unmatched brackets. No closing ']'"
      | code !! i == '[' = helper (i + 1) (n + 1)
      | code !! i == ']' = helper (i + 1) (n - 1)
      | otherwise        = helper (i + 1) n


run :: [BFCommand] -> Tape -> [Int] -> [Int] -> (Tape, [Int], [Int])
run [] tape input output = (tape, input, output)
run (cmd:restCmds) tape input output =
    case cmd of
        MoveRight -> run restCmds (moveRight tape) input output
        MoveLeft  -> run restCmds (moveLeft tape) input output
        Increment -> run restCmds (increment tape) input output
        Decrement -> run restCmds (decrement tape) input output
        Output -> run restCmds tape input (getValue tape : output)
        Input -> case input of
            [] -> error "Error: Out of input values."
            (x:xs) -> run restCmds (setValue x tape) xs output
        Loop loop ->
            if getValue tape == 0
                then run restCmds tape input output
                else run (Loop loop : restCmds) updatedTape updatedInput updatedOutput
            where
                (updatedTape, updatedInput, updatedOutput) = run loop tape input output

concatPrograms  :: FilePath -> FilePath -> [Int] -> IO [Int]
concatPrograms  pFile qFile input = do
    pOutput <- brainfuck pFile input
    print pOutput
    brainfuck qFile pOutput

parallelPrograms :: FilePath -> FilePath -> [Int] -> IO [Int]
parallelPrograms pFile qFile input = do
    pOutput <- brainfuck pFile input
    qOutput <- brainfuck qFile input
    let combinedOutput = pOutput ++ qOutput
    return combinedOutput

split :: [Int] -> ([Int], [Int])
split [] = ([], [])
split [x] = ([x], [])
split (x:y:xs) = (x : px, y : qx)
  where
    (px, qx) = split xs

mergeOutputs :: [Int] -> [Int] -> [Int]
mergeOutputs [] ys = ys
mergeOutputs xs [] = xs
mergeOutputs (x:xs) (y:ys) = x : y : mergeOutputs xs ys

alternatePrograms :: FilePath -> FilePath -> [Int] -> IO [Int]
alternatePrograms pFile qFile input = do
    let (pInput, qInput) = split input
    pOutput <- brainfuck pFile pInput
    qOutput <- brainfuck qFile qInput
    let combinedOutput = mergeOutputs pOutput qOutput
    return combinedOutput

brainfuck :: FilePath -> [Int] -> IO [Int]
brainfuck fileName numbers = do
    code <- readFile fileName  
    let commands = parseBF code  
    let tape = initTape 1000  
    let (_, _, output) = run commands tape numbers []  
    return $ reverse output 

