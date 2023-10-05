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
import qualified Data.Vector as V

file = "/home/candyman/Downloads/test.csv"

data sRow = sRow 	{ sname :: !String
					, sabout :: !String
					, percentables :: !String}
	deriving (Generic, Eq, Show)

instance FromNamedRecord Thing where
	parseNamedRecord x = fmap Thing (x .: "index") 

instance ToNamedRecord Thing
instance DefaultOrdered Thing



readFromFile :: IO ()
readFromFile = do
	f <- BL.readFile file 
	case (decodeByName f) of 
		Left err -> putStrLn err
		Right (_, v) -> V.forM_ v (\x -> print $ iindex x)





main :: IO ()
main = readFromFile 
