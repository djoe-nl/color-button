{-# LANGUAGE OverloadedStrings #-}
module Main (main) where

import Control.Monad (forever, (>=>))
import Control.Concurrent (forkIO)
import qualified Control.Concurrent.Broadcast as BC
import Data.ByteString (ByteString)
import Data.IORef
import qualified Network.WebSockets as WS
import Network.Socket.ByteString
import Network.Run.UDP

data Chan = Chan (IORef ByteString) (BC.Broadcast ByteString)

send_msg :: Chan -> ByteString -> IO ()
send_msg (Chan r c) msg = do
    BC.signal c msg
    writeIORef r msg

main :: IO ()
main = do
    chan <- Chan <$> newIORef "\0\0\0\0" <*> BC.new
    _ <- forkIO (inputloop chan)
    WS.runServer "0.0.0.0" 61228 $ WS.acceptRequest >=> application chan

inputloop :: Chan -> IO ()
inputloop chan = runUDPServer Nothing "61227" $ \s -> do
    forever $ recv s 4 >>= send_msg chan

application :: Chan -> WS.Connection -> IO ()
application (Chan r c) conn = do
    readIORef r >>= WS.sendBinaryData conn
    forever $ BC.listen c >>= WS.sendBinaryData conn
