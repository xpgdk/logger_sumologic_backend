defmodule LoggerSumologicBackend.Clients.HTTPoisonTest do
  
  use ExUnit.Case

  alias LoggerSumologicBackend.Clients
  alias LoggerSumologicBackend.Entry

  setup do    
    endpoint = """
"""
    client_id = Clients.HTTPoison.init([
      endpoint: endpoint,
      format: "[$date $time] - $level [$metadata] message=$message",
      ])

    {:ok, 
      client_id: client_id
    }
  end

  test "Log one entry", tags do
    entry = %Entry{
      level: :warn,
      message: "Testing",
      timestamp: {{2017, 01, 02}, {12, 00, 01, 23}},
      metadata: [],
    }

    Clients.HTTPoison.log_event(tags.client_id, [entry])
  end

  test "Log multiple short entries", tags do
    entry1 = %Entry{
      level: :warn,
      message: "Testing",
      timestamp: {{2017, 01, 02}, {12, 00, 01, 23}},
      metadata: [],
    }

    entry2 = %Entry{
      level: :warn,
      message: "Hello world, how are you?",
      timestamp: {{2017, 01, 02}, {14, 00, 01, 23}},
      metadata: [something: 2],
    }

    Clients.HTTPoison.log_event(tags.client_id, [entry1, entry2])
  end

  test "Log multiple multi-line entries", tags do
    entry1 = %Entry{
      level: :warn,
      message: """
      Uhh, a long entry:
      Stacktrace:
       1. Somewhere
       2. Somewhere else
      """,
      timestamp: {{2017, 01, 02}, {12, 00, 01, 23}},
      metadata: [],
    }

    entry2 = %Entry{
      level: :warn,
      message: """
      Hello world, how are you?
      I'm good!
      """,
      timestamp: {{2017, 01, 02}, {14, 00, 01, 23}},
      metadata: [something: 2],
    }

    Clients.HTTPoison.log_event(tags.client_id, [entry1, entry2])
  end

  test "Log multiple short entries with metadata", tags do
    entry1 = %Entry{
      level: :warn,
      message: "Testing with metadata",
      timestamp: {{2017, 01, 02}, {12, 00, 01, 23}},
      metadata: [meta1: 1, meta2: 2, long_value: "string with spaces"],
    }

    entry2 = %Entry{
      level: :warn,
      message: "Hello world, how are you? I have metadata too!",
      timestamp: {{2017, 01, 02}, {14, 00, 01, 23}},
      metadata: [something: 2, somewhat_long_key_with_long_value: "long string with plenty o  f  s p a  c es"],
    }

    Clients.HTTPoison.log_event(tags.client_id, [entry1, entry2])
  end


end