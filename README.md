# LoggerSumologicBackend

Logger backend, which logs to Sumologic using their [HTTP Source](https://help.sumologic.com/Send_Data/Sources/02Sources_for_Hosted_Collectors/HTTP_Source).

## Configuration

The Sumologic backend has two required options:
 - `format` The format description string to use to generate log messages.
 - `endpoint` The HTTP endpoint to use for logging.

 An additional option `batch_timeout` can be used to specify for how long the Logger backend should wait for
 messages before sending them to Sumologic.
