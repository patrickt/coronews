{-# LANGUAGE DeriveAnyClass, DeriveGeneric, DerivingStrategies, GeneralizedNewtypeDeriving, OverloadedLabels,
             OverloadedStrings, RecordWildCards, TypeApplications #-}
module Covid
  ( Stats (..)
  , Reports
  , download
  ) where

import           Control.Lens hiding ((:>))
import           Data.Aeson
import           Data.Aeson.Lens
import           Data.ByteString.Streaming.Aeson
import           Data.ByteString.Streaming.HTTP
import           Data.Foldable
import           Data.Generics.Labels ()
import           Data.Ord
import           Data.Text (Text)
import           Data.Text.Prettyprint.Doc ((<+>))
import qualified Data.Text.Prettyprint.Doc as Doc
import           Data.Time.Clock
import           Display
import           GHC.Generics (Generic)
import           Streaming
import qualified Streaming.Prelude as Streaming
import           System.Exit

data Stats = Stats
  { confirmed  :: Int
  , recovered  :: Int
  , deaths     :: Int
  , lastUpdate :: UTCTime
  } deriving stock (Show, Generic)

instance Display Stats where
  display s = Doc.vcat [ "Confirmed: " <> Display.yellow (s ^. #confirmed.to display)
                       , "Recovered: " <> Display.green (s ^. #recovered.to display)
                       , "Deaths:    " <> Display.red (s ^. #deaths.to display)
                       , "Updated:   " <> (s ^. #lastUpdate.to display)
                       ] <> Doc.hardline

instance FromJSON Stats where
  parseJSON = withObject "stats" $ \o -> do
    Just confirmed  <- pure (o ^? ix "confirmed".key "value"._Integral)
    Just recovered  <- pure (o ^? ix "recovered".key "value"._Integral)
    Just deaths     <- pure (o ^? ix "deaths".key "value"._Integral)
    Just lastUpdate <- pure (o ^? ix "lastUpdate"._JSON)
    pure Stats{..}

data Report = Report
  { reportDate       :: Int
  , mainlandChina    :: Int
  , otherLocations   :: Int
  , totalConfirmed   :: Int
  , totalRecovered   :: Maybe Int
  , reportDateString :: Text
  , deltaConfirmed   :: Int
  , deltaRecovered   :: Maybe Int
  }
  deriving stock Generic
  deriving anyclass FromJSON

instance Display Report where
  display r =
    Doc.vcat [ "China:    " <+> Display.yellow (display (r ^. #mainlandChina))
             , "Other:    " <+> Display.yellow (display (r ^. #otherLocations))
             , "Confirmed:" <+> Display.yellow (display (r ^. #totalConfirmed)) <+> delta (r ^. #deltaConfirmed)
             , "Recovered:" <+> Display.green (display (r ^. #totalRecovered)) <+> delta (r ^. #deltaRecovered . non 0)
             ] <> Doc.hardline
    where
      delta n
        | n > 0 = Doc.parens ("+" <> Display.red (display n))
        | otherwise = Doc.parens (Display.green (display n))

newtype Reports = Reports { getReports :: [Report]}
  deriving newtype FromJSON

instance Display Reports where
  display = display . maximumBy (comparing (view #reportDate)) . getReports

download :: FromJSON a => String -> IO (Either DecodingError a)
download url = do
  req    <- parseRequest url
  mgr    <- newManager tlsManagerSettings
  (mResult :> err) <- withHTTP req mgr (Streaming.head . decoded . responseBody)
  case (err, mResult) of
    (Right _, Just a) -> pure $ Right a
    (Left (e, _), _)  -> pure $ Left e
    _                 -> die "download: unhandled result case"
