module Config where

newtype Header = Header String String
data HttpMethod = GET | POST | PUT | PATCH | DELETE

-- Assume failure case unless there's a specific retry case

data ExpectedResponse = {
    expectedBody :: Maybe Text, -- Regex?
    expectedStatusCode :: [StatusCode]
} deriving (Show, Eq)

data Authorization = Basic Text | Bearer Text | OAuth Text Text

instance Show Authorization where
    shows = "<secret>"

data Retry = Retry {
    -- You only want to retry for specific cases.
    -- If not specificed then will retry on all cases
    onlyRetryOn :: Maybe ExpectedResponse
}

data KafkaConfig = KafkaConfig {
    topic :: Topic,
    group :: Group
} deriving (Show, Eq)


data Config = Config {
    headers :: [Header],
    type :: HttpMethod,
    url :: Text,
    -- A template refer to items from th
    body :: Text,
    expectedResponse :: ExpectedResponse,
    -- Do you want to attempt retrying?
    retry :: Maybe Retry
    -- If you are unable to get a successful request then put the message in a new topic (dead letter queue).
    deadLetterQueue :: Maybe Topic,
    authorization :: Authorization,
    -- How fast to throttle service
    throttle :: Millisecond,
} deriving Show

