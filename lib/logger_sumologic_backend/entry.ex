defmodule LoggerSumologicBackend.Entry do
  @type t :: %__MODULE__{}
  defstruct [
    level: nil,
    message: "",
    timestamp: nil,
    metadata: []
  ] 
end