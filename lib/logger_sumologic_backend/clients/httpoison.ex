defmodule LoggerSumologicBackend.Clients.HTTPoison do
  @behaviour LoggerSumologicBackend.Client

  def init(config) do
    endpoint = Keyword.get(config, :endpoint)
    if endpoint == nil do
      exit "#{__MODULE__} requires 'endpoint' to be set."
    end

    %{
      endpoint: endpoint,
      compiled_format: Logger.Formatter.compile(Keyword.get(config, :format)),
    }
  end

  def log_event(config, entries) do
    {:ok, resp} = HTTPoison.post(config.endpoint, generate_body(config, entries))
    if resp.status_code != 200 do
      IO.puts("Failed to send request to \"#{config.endpoint}\", expected 200 got #{resp.status_code}")
    end
    :ok
  end
  
  def generate_body(config, entries) do
    formatted_entries = Enum.map(entries, fn e -> 
      Logger.Formatter.format(config.compiled_format, e.level, e.message, e.timestamp, e.metadata)
    end)
    Enum.join(formatted_entries, "\n")
  end

end