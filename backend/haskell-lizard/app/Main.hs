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
import System.Command
import System.Directory
import qualified Data.Vector as V


file = "output.csv"
storeFolder = "gits"

data SRow = SRow    { project :: !String
				    , repositoryUrl :: !String
					, about :: !String
                    , licence :: !String
                    , starts :: !String
                    }
	deriving (Generic, Eq, Show)

-- instance FromNamedRecord SRow where
	-- parseNamedRecord x = fmap SRow (x .: "User/Project") 

instance ToNamedRecord SRow
instance FromNamedRecord SRow where
	parseNamedRecord x = SRow <$> x .: "User/Project" <*> x .: "Repository URL" <*> x .: "About" <*> x .: "License" <*> x .: "Stars"
instance DefaultOrdered SRow

getGits :: FilePath -> IO [String]
getGits = listDirectory 

pullGits :: FilePath -> [String] -> IO () 
pullGits f l =  do 
    mapM_ (\x -> print =<< getGits f) l

pullGit :: String -> IO() 
pullGit f = runCommand "git clone " ++ f



readFromFile :: IO ()
readFromFile = do
	f <- BL.readFile file 
	case (decodeByName f) of 
		Left err -> putStrLn err
		Right (_, v) -> V.forM_ v (\x -> print $ project x)





main :: IO ()
main = readFromFile 
