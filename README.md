# LoggerSumologicBackend

Logger backend, which logs to Sumologic using their [HTTP Source](https://help.sumologic.com/Send_Data/Sources/02Sources_for_Hosted_Collectors/HTTP_Source).

## Configuration

The Sumologic backend has two required options:
 - `format` The format description string to use to generate log messages.
 - `endpoint` The HTTP endpoint to use for logging.

The following options are optional:
 - `metadata` List of meta-data keys to log.
 - `batch_timeout` Specifies how long the Logger backend accumulates messages before sending them to Sumologic.
 - `source_name` Specifies the source name to use.
 - `source_category` Specifies the source category to use.

Example configuration:
```
config :logger, :sumologic,
  format: "[$date $time] - $level [$metadata] message=$message",
  metadata: [:request_id, :module, :line],
  source_category: "develop/backend",
  source_name: "elixir",
  endpoint: """
https://endpoint1.collection.eu.sumologic.com/receiver\
/v1/http/dassaddd23eqwd987y12983rfehci34vt984375098f3d4dm0tn3e
"""

```

## Test

In order to be able to run the test-suite, the 'endpoint' variable in ``test/clients/httpoison_test.exs`` must be
set.
