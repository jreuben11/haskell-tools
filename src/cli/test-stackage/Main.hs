{-# LANGUAGE LambdaCase
           , TypeApplications
           , TupleSections
           , ScopedTypeVariables
           #-}
module Main where

import Control.Applicative ((<$>))
import Control.Exception (SomeException, try)
import Control.Monad
import Data.List
import Data.List.Split (splitOn)
import Data.Semigroup ((<>))
import Options.Applicative
import System.Directory (removeDirectoryRecursive, getCurrentDirectory, createDirectoryIfMissing)
import System.Exit (ExitCode(..))
import System.FilePath (FilePath, (</>))
import System.FilePath.Glob ()
import System.Process

main :: IO ()
main = testStackage =<< execParser opts
  where opts = info (options <**> helper)
                    (fullDesc
                      <> progDesc "Tests the Haskell-tools framework with stackage packages."
                      <> header "ht-test-stackage: a tester utility for Haskell-tools")

options :: Parser StackageTestConfig
options = StackageTestConfig <$> noload <*> noretest <*> noclean <*> result <*> srcdir <*> logdir <*> inputfile <*> snapshot
  where noload = switch (long "no-load"
                           <> help "Don't download the package, use the existing sources.")
        noretest = switch (long "no-retest"
                             <> help "Don't run the test on packages already in the results file.")
        noclean = switch (long "no-clean"
                             <> help "Keep the refactored files.")
        srcdir
          = strOption (long "src-dir"
                         <> short 't'
                         <> metavar "PATH"
                         <> showDefault
                         <> value "stackage-test"
                         <> help "The directory where the downloaded sources should be stored.")
        logdir
          = strOption (long "log-dir"
                         <> short 'l'
                         <> metavar "PATH"
                         <> showDefault
                         <> value "stackage-test-logs"
                         <> help "The directory where the log files should be stored.")
        snapshot
          = optional (strOption (long "snapshot"
                                   <> metavar "SNAPSHOT"
                                   <> help "The stackage snapshots identifier."))
        result
          = strOption (long "result"
                         <> short 'r'
                         <> metavar "FILE"
                         <> showDefault
                         <> value ("results.csv")
                         <> help "The text file where the results are stored in csv format.")
        inputfile = strArgument (metavar "FILE")


data StackageTestConfig = StackageTestConfig { noLoad :: Bool
                                             , noRetest :: Bool
                                             , noClean :: Bool
                                             , resultFile :: FilePath
                                             , sourceDirectory :: FilePath
                                             , logDirectory :: FilePath
                                             , inputFile :: FilePath
                                             , stackageSnapshot :: Maybe String
                                             }

testStackage :: StackageTestConfig -> IO ()
testStackage config = do
    packages <- lines <$> readFile (inputFile config)
    alreadyTested
      <- if noRetest config
           then do appendFile (resultFile config) ""
                   map (head . splitOn ";") . filter (not . null) . lines
                     <$> readFile (resultFile config)
           else writeFile (resultFile config) "" >> return []
    let filteredPackages = packages \\ alreadyTested
    createDirectoryIfMissing False (logDirectory config)
    mapM_ testAndEvaluate filteredPackages
  where testAndEvaluate p = do
          (res, problem) <- testPackage (noLoad config) (noClean config) (sourceDirectory config)
                                        (logDirectory config) (stackageSnapshot config) p
          appendFile (resultFile config) (p ++ ";" ++ show res ++ " ; " ++ problem ++ "\n")


testPackage :: Bool -> Bool -> FilePath -> FilePath -> Maybe String -> String -> IO (Result, String)
testPackage noLoad noClean sourceDirectory logDirectory resolver pack = do
  baseDir <- getCurrentDirectory
  let pkgLoc = baseDir </> sourceDirectory </> pack
      buildLogPath = baseDir </> logDirectory </> (pack ++ "-build-log.txt")
      refLogPath = baseDir </> logDirectory </> (pack ++ "-refact-log.txt")
      reloadLogPath = baseDir </> logDirectory </> (pack ++ "-reload-log.txt")
  res <- runCommands (if noClean then return () else cleanup pkgLoc)
           $ init
               ++ load
               ++ [ Left ("stack init" ++ (maybe "" (" --resolver="++) resolver) ++ " > " ++ buildLogPath ++ " 2>&1", pkgLoc, BuildFailure)
                  , Left ("stack build --test --no-run-tests --bench --no-run-benchmarks --ghc-options=\"-w\" > "
                             ++ buildLogPath ++ " 2>&1", pkgLoc, BuildFailure)
                  -- correct rts option handling (on windows) requires stack 1.4
                  , Left ("stack exec --RTS -- ht-refact +RTS -M4G -RTS --no-watch --ghc-options=\"-w\" "
                            ++ " --execute=\"ProjectOrganizeImports\" . > "
                            ++ refLogPath ++ " 2>&1", pkgLoc, RefactError)
                  , Left ("stack build > " ++ reloadLogPath ++ " 2>&1", pkgLoc, WrongCodeError)
                  ]
  problem <- case res of
               RefactError -> map (\case '\n' -> ' '; c -> c) <$> readFile refLogPath
               WrongCodeError -> map (\case '\n' -> ' '; c -> c) <$> readFile reloadLogPath
               _ -> return ""
  return (res, problem)
  where load = if noLoad
                 then []
                 else [ Right $ (either (\(e :: SomeException) -> return ()) return =<<)
                              $ try (removeDirectoryRecursive (sourceDirectory </> pack))
                      , Left ("cabal get -d " ++ sourceDirectory ++ " " ++ pack, ".", GetFailure) ]
        init = [ Right (forM_ [sourceDirectory,logDirectory] (createDirectoryIfMissing True)) ]
        cleanup pkgLoc = either (print @SomeException) return =<< try (removeDirectoryRecursive pkgLoc)

data Result = GetFailure
            | BuildFailure
            | RefactError
            | WrongCodeError
            | OK
  deriving Show

runCommands :: IO () -> [Either (String, FilePath, Result) (IO ())] -> IO Result
runCommands final [] = final >> return OK
runCommands final (Left (cmd,wd,failRes) : rest) = do
  baseDir <- getCurrentDirectory
  let sh = shell cmd
  (_, _, _, pr) <- createProcess sh{ cwd = Just (baseDir </> wd) }
  exitCode <- waitForProcess pr
  case exitCode of ExitSuccess -> runCommands final rest
                   ExitFailure _ -> final >> return failRes
runCommands final (Right act : rest) = act >> runCommands final rest
