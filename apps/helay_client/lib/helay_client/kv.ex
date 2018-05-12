defmodule HelayClient.KV do
  use Agent

  def start_link(opts) do
    Agent.start_link(fn -> Map.new() end, opts)
  end

  def get(pid, key) do
    Agent.get(pid, &Map.get(&1, key))
  end

  def get_or_default(pid, key, default) do
    get(pid, key) || default
  end

  def get_all(pid) do
    Agent.get(pid, &Map.values(&1))
  end

  def has?(pid, key) do
    Agent.get(pid, &Map.has_key?(&1, key))
  end

  def put(pid, key, data) do
    case Agent.update(pid, &Map.put(&1, key, data)) do
      :ok -> {:ok, data}
      {:error, _reason} = err -> err
    end
  end
end
