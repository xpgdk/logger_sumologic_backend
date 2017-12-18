defmodule LoggerSumologicBackend.Clients.HTTPoison do
  @behaviour LoggerSumologicBackend.Client

  def init(config) do
    endpoint = Keyword.get(config, :endpoint)
    if endpoint == nil do
      exit "#{__MODULE__} requires 'endpoint' to be set."
    end

    hostname =
      case :inet.gethostname() do
        {:ok, hostname} -> hostname
        _ -> nil
      end

    source_name = Keyword.get(config, :source_name, nil)
    source_category = Keyword.get(config, :source_category, nil)

    headers = []
      |> add_header("X-Sumo-Name", source_name)
      |> add_header("X-Sumo-Category", source_category)
      |> add_header("X-Sumo-Host", hostname)

    %{
      endpoint: endpoint,
      compiled_format: Logger.Formatter.compile(Keyword.get(config, :format)),
      headers: headers,
    }
  end

  def log_event(config, entries, retry \\ 4)
  def log_event(_config, _entries, 0) do
    IO.puts("LoggerSumologicBackend: Giving up on sending request")
  end
  def log_event(config, entries, retry) do
    case HTTPoison.post(config.endpoint, generate_body(config, entries), config.headers) do
      {:ok, resp} ->
        if resp.status_code != 200 do
          IO.puts("LoggerSumologicBackend: Failed to send request to \"#{config.endpoint}\", expected 200 got #{resp.status_code}. Retries left: #{Integer.to_string(retry)}")
          log_event(config, entries, retry-1)
        end
        if retry < 4 do
          IO.puts("LogggerSumologicBackend: Success with retry = #{Integer.to_string(retry)}")
        end
      {:error, reason} ->
        IO.puts("LoggerSumologicBackend: Failed to send request: #{inspect reason}. Retries left: #{Integer.to_string(retry)}")
        log_event(config, entries, retry-1)
    end
    :ok
  end

  defp generate_body(config, entries) do
    formatted_entries = Enum.map(entries, fn e ->
      Logger.Formatter.format(config.compiled_format, e.level, e.message, e.timestamp, e.metadata)
    end)
    Enum.join(formatted_entries, "\n")
  end

  defp add_header(header_list, _name, nil) do
    header_list
  end
  defp add_header(header_list, name, value) do
    [{name, value} | header_list]
  end

end
