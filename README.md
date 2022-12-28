# kafka2http

## Simple Example
You just have some topic and you want to hit some API endpoint when you get a message.

1. Get a message from the users topic
1. POST to /users/create

```yaml
kafka:
    topic: ping
    group: a
http:
    method: POST
    url: http://myapi.com/users/pong
```

## Templated requests based on body

You can template a http request based on the contents of the body.

```yaml
http:
    method: POST
    url: http://myapi.com/users/create
    body: |
        {
            userId: ${msgBody.user.id},
            lovesCats: True
        }
```

## More sophisticated example

The above examples can be useful but often there are other concerns.

1. What if you want to keep retrying?
1. What if we want to only retry in speific cases?
1. What about authentication?


The following example demonstrates:

1. Get a message from the users topic
1. POST to /users/create
1. Templatize body of request based on message contents
1. Retry but only on 500 errors
1. If either there is a failure or the retry limit is reached put it in another topic for retrivial later (dead letter queue)
1. Throttle service so that it doesn't overwhelm the receiving service

```yaml
kafka:
    topic: users
    group: a
http:
    method: POST
    url: http://myapi.com/users/create
    body: |
        {
            userId: ${msgBody.user.id},
            lovesCats: True
        }
    headers:
        Content-Type: application/json
    authorization: Bearer
retry:
    onlyRetryOn:
        - statusCode: 5xx
onlyRetryOn:
    5**
deadLetterQueue: users-dlq
```

## Limitations

* Only supports json encoded messages for now.
* This is meant to be a simple service and you might have more sophisticated needs.
    * If we are not able to accommodate you may want to build your own service or make a fork.