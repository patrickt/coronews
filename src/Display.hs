{-# LANGUAGE FlexibleInstances, OverloadedStrings, UndecidableInstances #-}
module Display
  ( Display (..)
  , displayException
  , yellow
  , red
  , green
  ) where

import qualified Control.Exception as Exc
import           Data.Text.Prettyprint.Doc (Doc)
import qualified Data.Text.Prettyprint.Doc as Doc
import           Data.Text.Prettyprint.Doc.Render.Terminal (AnsiStyle)
import qualified Data.Text.Prettyprint.Doc.Render.Terminal as Ansi
import           Data.Time.Clock
import           Data.Time.Format

class Display a where
  display :: a -> Doc AnsiStyle

instance Display Int where
  display = Doc.viaShow

instance Display String where
  display = Doc.pretty

instance Display UTCTime where
  display = Doc.pretty . formatTime defaultTimeLocale rfc822DateFormat

instance Display a => Display (Maybe a) where
  display = maybe "(null)" display

displayException :: Exc.Exception e => e -> Doc AnsiStyle
displayException = display . Exc.displayException

withColor :: Ansi.Color -> Doc a -> Doc AnsiStyle
withColor c = Doc.annotate (Ansi.color c) . Doc.unAnnotate

yellow, red, green :: Doc a -> Doc AnsiStyle
yellow = withColor Ansi.Yellow
red = withColor Ansi.Red
green = withColor Ansi.Green
