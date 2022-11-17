{-# LANGUAGE OverloadedStrings #-}
module Main (main) where
import Data.Text (Text)
import Control.Monad (forever, (>=>))
import Control.Concurrent (forkIO)
--import qualified Data.Text as T
import qualified Data.Text.IO as T
import qualified Network.WebSockets as WS
import qualified Control.Concurrent.Broadcast as BC


type Chan = BC.Broadcast Text

main :: IO ()
main = do
    chan <- BC.new
    _ <- forkIO (inputloop chan)
    WS.runServer "0.0.0.0" 61228 $ WS.acceptRequest >=> application chan

inputloop :: Chan -> IO ()
inputloop chan = forever $ T.getLine >>= BC.signal chan

application :: Chan -> WS.Connection -> IO ()
application chan conn = forever $ BC.listen chan >>= WS.sendTextData conn
