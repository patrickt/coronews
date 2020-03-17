module Display
  ( Display (..)
  , yellow
  ) where

import           Data.Text.Prettyprint.Doc (Doc)
import qualified Data.Text.Prettyprint.Doc as Doc

class Display a where
  display :: a -> Doc x

instance Display Int where
  display = Doc.viaShow

yellow :: Doc a -> Doc a
yellow = id
