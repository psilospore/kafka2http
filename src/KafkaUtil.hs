import Control.Exception (bracket)
import Kafka.Consumer

module KafkaUtil where

-- Global consumer properties
mkConsumerProps :: Text -> Text -> ConsumerProperties
mkConsumerProps broker group = brokersList [broker]
             <> groupId group
             <> noAutoCommit
             <> logLevel KafkaLogInfo

-- Subscription to topics
mkConsumerSub :: Text -> Subscription
mkConsumerSub topic = topics topic
           <> offsetReset Earliest

-- Running an example
runConsumerExample :: ConsumerProperties -> Subscription -> IO ()
runConsumerExample consumerProps consumerSub = do
    res <- bracket mkConsumer clConsumer runHandler
    print res
    where
      mkConsumer = newConsumer consumerProps consumerSub
      clConsumer (Left err) = return (Left err)
      clConsumer (Right kc) = maybe (Right ()) Left <$> closeConsumer kc
      runHandler (Left err) = return (Left err)
      runHandler (Right kc) = processMessages kc

-------------------------------------------------------------------
processMessages :: KafkaConsumer -> IO (Either KafkaError ())
processMessages kafka = do
    replicateM_ 10 $ do
      msg <- pollMessage kafka (Timeout 1000)
      putStrLn $ "Message: " <> show msg
      err <- commitAllOffsets OffsetCommit kafka
      putStrLn $ "Offsets: " <> maybe "Committed." show err
    return $ Right ()
