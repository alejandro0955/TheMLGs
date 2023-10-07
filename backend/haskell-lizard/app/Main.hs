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

file = "../../OneDrive/Desktop/WebScraping/output.csv"

storeFolder = "gits"

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

-- getGits :: FilePath -> IO [String]
-- getGits = listDirectory 

pullGits :: FilePath -> V.Vector (String, String) -> IO () 
pullGits f l =  V.mapM_ (\(name,url) -> withCurrentDirectory f (runCommand ("git clone " ++ url) )) l


readFromFile :: IO ()
readFromFile = do
	f <- BL.readFile file 
	case (decodeByName f) of 
		Left err -> putStrLn err
		Right (_, v) -> pullGits storeFolder $ (getListProjects v)
    where
    	getListProjects v = V.map (\x -> (project x, repositoryUrl x) ) v





main :: IO ()
main = readFromFile 
