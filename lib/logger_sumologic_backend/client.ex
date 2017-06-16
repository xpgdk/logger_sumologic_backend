defmodule LoggerSumologicBackend.Client do

  alias LoggerSumologicBackend.Entry

  @callback init(Keyword.t) :: any

  @callback log_event(any, [Entry.t]) :: :ok  
end