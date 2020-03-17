{-# LANGUAGE DeriveGeneric, DerivingStrategies, OverloadedLabels, OverloadedStrings #-}
module Covid
  ( Stats (..)
  ) where

import           Control.Lens.Getter
import qualified Data.Text.Prettyprint.Doc as Doc
import           Data.Time.LocalTime
import           Display
import           GHC.Generics (Generic)

data Stats = Stats
  { confirmed   :: !Int
  , recovered   :: !Int
  , deaths      :: !Int
  , lastUpdated :: !ZonedTime
  } deriving stock (Show, Generic)

instance Display Stats where
  display s = Doc.vcat [ "Confirmed: " <> Display.yellow (s ^. to confirmed . to display)
                       ]
