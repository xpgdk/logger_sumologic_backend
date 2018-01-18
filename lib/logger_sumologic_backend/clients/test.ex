defmodule LoggerSumologicBackend.Clients.Test do

  @behaviour LoggerSumologicBackend.Client

  def init(config) do
    delay = Keyword.get(config, :delay, 0)
    %{
      delay: delay
    }
  end

  def log_event(config, message) do
    :timer.sleep(config.delay)
    send receiver(), {__MODULE__, message}
    :ok
  end

  def start() do
    reciever_pid = self()
    Agent.start_link(fn -> reciever_pid end, name: __MODULE__)
  end

  defp receiver() do
    Agent.get(__MODULE__, fn pid -> pid end)
  end
end
