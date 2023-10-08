{-# LANGUAGE BangPatterns      #-}
{-# LANGUAGE DeriveGeneric     #-}
{-# LANGUAGE LambdaCase        #-}
{-# LANGUAGE OverloadedStrings #-}


module Main where
import Data.Csv as C
--import Data.Text (Text)
import Data.Maybe
import qualified Data.Csv.Incremental as I
import Text.Read
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
fileSmall =  "/home/candyman/Downloads/githubscraper.csv"
endF = "results.csv"

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

data Results =  Results { nloc :: !Double
                        , avgNloc :: !Double
                        , avgCcn :: !Double
                        , avgToken :: !Double
                        , fCnt :: !Double
                        } deriving (Generic, Show) 

instance FromNamedRecord Results
instance ToNamedRecord Results
instance DefaultOrdered Results
instance ToRecord Results


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
    -- descends into gits
    results <- withCurrentDirectory f (procedure l)
    -- first one
    return $ results
    where 
        -- ListP  is (Project, Url)
        procedure listP = V.mapM (perFolder) listP

        -- IO Action to be run in each folder, wrapped as a tuple with the name of its project descends into
        -- Projects folder
        -- perFolder :: (String, String) -> IO (a)

        perFolder (name,url) =  do 
            -- List of lizard results
            lizardResults <- withCurrentDirectory name (releaseLizardParsed)
            -- folders <- withCurrentDirectory name (readProcess "pwd" [] "") 
            return (name, lizardResults)

releaseLizard = do 
    (_, output, _) <- readProcessWithExitCode "lizard" [] []
    return output

releaseLizardParsed = do 
    (_, output, _) <- readProcessWithExitCode "lizard" [] []
    -- String 
    let lin = head $ take 2 $ reverse $ lines output
    -- return vals
    -- list of String
    return $ lparse $ take 5 $ words lin

lparse x = do 
    -- return vals
    let listM = map (\x -> readMaybe x :: Maybe Double ) x
    let trash = or $ map (isNothing) listM 
    if trash 
        then (Results (-1.0) (-1.0) (-1.0) (-1.0) (-1.0))
    else (results $ map (\x -> fromJust x) listM)
    where
        results [a,b,c,e,f] = Results a b c e f
        results a = Results (-1.0) (-1.0) (-1.0) (-1.0) (-1.0)

writeToCsv fapp l = do
    let list = V.toList $ V.map (\(_,y) -> y) l
    let file2 = encodeDefaultOrderedByName  list
    BL.writeFile endF file2



    --print list


readFromFile :: IO ()
readFromFile = do
	f <- BL.readFile fileSmall
	case (decodeByName f) of 
		Left err -> putStrLn err
		-- Right (_, v) -> print $ (getListProjects v)
		---Right (_, v) -> pullGits storeFolder (getListProjects v)

		Right (_, v) ->  writeToCsv f =<< ((lizardProcedure storeFolder) $ (getListProjects v))
    where
    	getListProjects v = V.map (\x -> (project x, repositoryUrl x) ) v




main :: IO ()
main = readFromFile 
