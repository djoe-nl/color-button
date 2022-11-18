module Main (main) where

import Control.Monad (forever)
import Data.ByteString (hGet)
import Data.Serialize.Get
import Data.Serialize.Put
import System.Environment (getArgs)
import System.Hardware.Serialport
import Network.Socket.ByteString
import Network.Run.UDP

portSettings :: SerialPortSettings
portSettings = SerialPortSettings CS9600 8 One NoParity Software 2147483647

getPort :: [String] -> String
getPort [port] = port
getPort _      = "COM4"

main :: IO ()
main = do
    port <- getPort <$> getArgs
    hWithSerial port portSettings $ \h -> runUDPClient "production.server" "61227" $ \s a -> forever $ do
        Right n <- runGet getInt32le <$> hGet h 4
        sendAllTo s (runPut $ putInt32be n) a