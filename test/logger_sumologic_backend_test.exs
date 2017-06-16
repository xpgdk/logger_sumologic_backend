defmodule LoggerSumologicBackendTest do
  use ExUnit.Case

  alias LoggerSumologicBackend.Clients

  defp launch_logger(config) do

    current_config = Application.get_env(:logger, :sumologic)
    Application.put_env(:logger, :sumologic, Keyword.merge(current_config, config))

    {:ok, logger} = GenEvent.start_link()
    :ok = GenEvent.add_handler(logger, LoggerSumologicBackend, {LoggerSumologicBackend, :sumologic})
    logger
  end

  setup do
    Clients.Test.start()
    :ok
  end

  defp log(tags, level, message, timestamp, metadata \\ []) do
    GenEvent.notify(tags.logger, {level, nil, {Logger, message, timestamp, metadata}})
  end

  defp log_entries(timeout \\ 1000) do
    assert_receive {LoggerSumologicBackend.Clients.Test, entries}, timeout
    entries
  end

  defp no_log_entries(timeout) do
    refute_receive {LoggerSumologicBackend.Clients.Test, _entries}, timeout
  end

  describe "batch_timeout = 0" do

    setup do    
      {:ok,
        logger: launch_logger(batch_timeout: 0)
      }
    end

    test "log single entry", tags do     
      log tags, :warn, "Hello world", nil

      entries = log_entries()
      assert Enum.count(entries) == 1

      assert List.first(entries).message == "Hello world"
    end

    test "log multiple entries separatly", tags do     
      log tags, :warn, "Hello world", nil
      log tags, :warn, "Hello world 2", nil
      log tags, :warn, "Hello world 3", nil

      entries = log_entries()
      assert Enum.count(entries) == 1
      assert List.first(entries).message == "Hello world"

      entries = log_entries()
      assert Enum.count(entries) == 1
      assert List.first(entries).message == "Hello world 2"

      entries = log_entries()
      assert Enum.count(entries) == 1
      assert List.first(entries).message == "Hello world 3"
    end    
  end

  describe "batch_timeout = 500" do
    setup do
      {:ok,
        logger: launch_logger(batch_timeout: 500)
      }
    end

    test "log single entry", tags do
      log tags, :warn, "Hello world", nil

      no_log_entries(200)

      entries = log_entries()
      assert Enum.count(entries) == 1
      assert List.first(entries).message == "Hello world"      
    end

    test "batch multiple log entries into one", tags do
      log tags, :warn, "Hello world", nil
      log tags, :warn, "Hello world 2", nil
      log tags, :warn, "Hello world 3", nil


      entries = log_entries()
      assert Enum.count(entries) == 3

      assert Enum.map(entries, fn m -> m.message end) == ["Hello world", "Hello world 2", "Hello world 3"]
    end

    test "no empty entries" do
      no_log_entries(1000)
    end

  end
end
