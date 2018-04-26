# Helay
[![Build Status](https://travis-ci.org/drowzy/helay.svg?branch=master)](https://travis-ci.org/drowzy/helay)

Webhook relay

## Middlewares

* `jq` - Apply [jq](https://stedolan.github.io/jq/) transforms on data
* `http` - Send HTTP requests
* `console` - Default transforms, logs to stdout
* `file` - Write output to a provided file

## Templating

### Examples

```json
POST http://localhost:4001/middlewares
{
  "endpoint": "/hook",
  "transforms": [
    {
      "type": "http",
      "args": {
        "method": "POST",
        "uri": "https://httpbin.org/post",
        "headers": {
          "Content-Type": "application/json"
        },
        "body": {
          "hello": "world"
        }
      }
    },
    {
      "type": "jq",
      "args": "'{foo: .json}'"
    },
    {
      "type": "file",
      "args": {
        "path": "/home/helay/file.json"
      }
    }
  ]
}
```
