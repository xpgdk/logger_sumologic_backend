defmodule LoggerSumologicBackend.Clients.Test do

  @behaviour LoggerSumologicBackend.Client

  def init(_config) do
    :ok
  end

  def log_event(_config, message) do
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