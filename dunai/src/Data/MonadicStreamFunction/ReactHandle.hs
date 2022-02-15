-- | 'ReactHandle's.
--
-- Sometimes it is beneficial to give control to an external main loop,
-- for example OpenGL or a hardware-clocked audio server like JACK.
-- This module makes Dunai compatible with external main loops.

module Data.MonadicStreamFunction.ReactHandle where

-- External
import Control.Monad.IO.Class
import Data.IORef

-- Internal
import Data.MonadicStreamFunction
import Data.MonadicStreamFunction.InternalCore


-- | A storage for the current state of an 'MSF'.
-- The 'MSF' may not require input or produce output data,
-- all such data must be handled through side effects
-- (such as wormholes).
type ReactHandle m = IORef (MSF m () ())


-- | Needs to be called before the external main loop is dispatched.
reactInit :: MonadIO m => MSF n () () -> m (ReactHandle n)
reactInit = liftIO . newIORef


-- | The callback that needs to be called by the external loop at every cycle.
react :: MonadIO m => ReactHandle m -> m ()
react handle = do
  msf <- liftIO $ readIORef handle
  (_, msf') <- unMSF msf ()
  liftIO $ writeIORef handle msf'
