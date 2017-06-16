defmodule LoggerSumologicBackend do
  @moduledoc """
  Implements Logger backend for Sumologic.

  It uses the HTTP source as described 
  [here](https://help.sumologic.com/Send_Data/Sources/02Sources_for_Hosted_Collectors/HTTP_Source)
  """

  alias LoggerSumologicBackend.Entry

  use GenEvent

  defstruct [
    batch_timeout: 5_000,
    client: nil,
    client_id: nil,
    queue_agent: nil,
  ]

  def init({__MODULE__, logger_id}) do
    state = %__MODULE__{}

    config = Application.get_env(:logger, logger_id)

    client = Keyword.get(config, :client, LoggerSumologicBackend.Clients.HTTPoison)

    client_id = client.init(config)

    batch_timeout = Keyword.get(config, :batch_timeout, state.batch_timeout)

    queue_agent = 
      if batch_timeout == 0 do
        nil
      else
        {:ok, pid} = Agent.start_link(
          fn -> %{
            client: client,
            client_id: client_id,
            queue: []
          } 
        end)
        start_timer(batch_timeout, pid)
        pid
      end

    state = %{state | 
      client: client,
      client_id: client_id,
      batch_timeout: batch_timeout,
      queue_agent: queue_agent
    }

    {:ok, state}
  end

  def handle_event({level, _gl, {Logger, message, timestamp, metadata}}, state) do
    entry = %Entry{
      level: level,
      message: message,
      timestamp: timestamp,
      metadata: metadata
    }  
    {:ok, dispatch(state, entry)}
  end
  def handle_event(:flush, state) do
    IO.puts("Flush")
    {:ok, state}
  end

  def handle_call({:configure, options}, state) do
    IO.puts("Configure: #{inspect options}")
    {:ok, :ok, state}
  end

  def handle_info(msg, state) do
    IO.inspect(msg)
    {:ok, state}
  end

  defp dispatch(state, entry) do
    if state.batch_timeout == 0 do         
      state.client.log_event(state.client_id, [entry])
    else
      enqueue(state.queue_agent, entry)
    end
    state
  end


  defp enqueue(queue_agent, entry) do
    Agent.update(queue_agent, 
      fn state -> 
        %{state |
          queue: [ entry | state.queue]
        }
      end)
  end

  defp start_timer(timeout, agent_pid) do
    :timer.apply_after(timeout, __MODULE__, :timer_handler, [timeout, agent_pid])
  end

  def timer_handler(timeout, agent_pid) do
    Agent.update(agent_pid, fn state ->
      queue = Enum.reverse(state.queue)
      if Enum.count(queue) > 0 do
        state.client.log_event(state.client_id, queue)
      end
      %{state |
        queue: []
      }
    end)
    start_timer(timeout, agent_pid)
  end

end
