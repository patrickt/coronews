{-# LANGUAGE TypeApplications #-}
module Main (main) where

import           Covid
import qualified Data.Text.Prettyprint.Doc.Render.Terminal as Ansi
import           Display

-- data CLI = CLI
--   { showSummary :: Last Bool
--   , showReport  :: Last Bool
--   }
--   deriving stock (Eq, Show, Generic)
--   deriving anyclass (Semigroup, Monoid)


main :: IO ()
main = Covid.download "https://covid19.mathdro.id/api" >>= Ansi.putDoc . either displayException (display @Stats)
