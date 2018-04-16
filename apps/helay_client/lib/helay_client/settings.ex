defmodule HelayClient.Settings do
  use Agent

  def start_link(_) do
    IO.puts("startingnfnfnfnf")
    Agent.start_link(fn -> Map.new() end, name: __MODULE__)
  end

  def get(endpoint) do
    Agent.get(__MODULE__, &Map.get(&1, endpoint))
  end

  def get_all() do
    Agent.get(__MODULE__, &Map.values(&1))
  end

  def has?(endpoint) do
    Agent.get(__MODULE__, &Map.has_key?(&1, endpoint))
  end

  def put(endpoint, setting) do
    IO.puts("CALLING PUT #{endpoint}")
    Agent.update(__MODULE__, &Map.put(&1, endpoint, setting))
  end
end
