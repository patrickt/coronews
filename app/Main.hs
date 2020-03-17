{-# LANGUAGE DeriveAnyClass, DeriveGeneric, DerivingStrategies, RecordWildCards, TypeApplications #-}
module Main (main) where

import           Control.Monad
import           Covid
import           Data.Monoid.Generic
import qualified Data.Text.Prettyprint.Doc.Render.Terminal as Ansi
import           Display
import           GHC.Generics (Generic)
import qualified Options.Applicative as Opt

data CLI = CLI
  { showSummary :: Bool
  , showReport  :: Bool
  }
  deriving stock (Eq, Show, Generic)
  deriving anyclass (Semigroup, Monoid)

parser :: Opt.Parser CLI
parser = CLI
  <$> Opt.flag True False (Opt.long "no-summary")
  <*> Opt.switch (Opt.long "report")

main :: IO ()
main = do
  CLI{..} <- Opt.execParser (Opt.info parser mempty)
  when showSummary (Covid.download "https://covid19.mathdro.id/api" >>= Ansi.putDoc . either displayException (display @Stats))
  when showReport (Covid.download "https://covid19.mathdro.id/api/daily" >>= Ansi.putDoc . either displayException (display @Reports))
