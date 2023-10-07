{-# LANGUAGE BangPatterns      #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE OverloadedStrings #-}


module Main where
import Data.Csv as C
--import Data.Text (Text)
import GHC.Generics (Generic)
import qualified Data.ByteString.Lazy as BL
import System.IO
import System.Exit
import GHC.Generics
import System.Process
import System.Directory
import qualified Data.Vector as V

-- file = "../../OneDrive/Desktop/WebScraping/output.csv"
file = "../../OneDrive/Desktop/WebScraping/old.csv"

storeFolder = "gits"

lizardExecutable = "lizard"

data SRow = SRow    { user :: !String
                    , project :: !String
		            , repositoryUrl :: !String
                    , about :: !String
                    , licence :: !String
                    , starts :: !String
                    }
	deriving (Generic, Eq, Show)

instance ToNamedRecord SRow
instance FromNamedRecord SRow where
	parseNamedRecord x = SRow <$> x .: "User" <*> x .: "Project" <*> x .: "Repository URL" <*> x .: "About" <*> x .: "License" <*> x .: "Stars"
instance DefaultOrdered SRow

getGits :: FilePath -> IO [String]
getGits = listDirectory 

pullGits :: FilePath -> V.Vector (String, String) -> IO () 
pullGits f l =  V.mapM_ (\(name,url) -> withCurrentDirectory f (runCommand ("git clone " ++ url) )) l

-- lizardProcedure :: FilePath -> V.Vector (String, String) -> IO ()
lizardProcedure f l = do
    projectList <- getGits f
    -- This call should return a list of all results of lizard compiled already
    -- procedure should have the type of a [String]
    results <- withCurrentDirectory f (procedure l)
    V.mapM_ (\(_,x) -> putStrLn x )results
    where 
        procedure listP = V.mapM (perFolder) listP
        -- IO Action to be run in each folder, wrapped as a tuple with the name of its project
        -- perFolder :: (String, String) -> IO (a)
        perFolder (name,url) =  do 
            folders <- withCurrentDirectory name (releaseLizardParsed)
            -- folders <- withCurrentDirectory name (readProcess "pwd" [] "") 
            return (name, folders)

releaseLizard = do 
    (_, output, _) <- readProcessWithExitCode "lizard" [] []
    return output

releaseLizardParsed = do 
    (_, output, _) <- readProcessWithExitCode "lizard" [] []
    return $ head $ take 2 $ reverse $ lines output
    





readFromFile :: IO ()
readFromFile = do
	f <- BL.readFile file 
	case (decodeByName f) of 
		Left err -> putStrLn err
		-- Right (_, v) -> print $ (getListProjects v)
		Right (_, v) -> (lizardProcedure storeFolder) $ (getListProjects v)
    where
    	getListProjects v = V.map (\x -> (project x, repositoryUrl x) ) v






main :: IO ()
main = readFromFile 
