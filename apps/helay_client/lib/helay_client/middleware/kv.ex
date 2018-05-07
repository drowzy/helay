defmodule HelayClient.Middleware.KV do
  alias HelayClient.Middleware
  use Agent

  def start_link(_) do
    Agent.start_link(fn -> Map.new() end, name: __MODULE__)
  end

  def get(endpoint) do
    Agent.get(__MODULE__, &Map.get(&1, endpoint))
  end

  def get_or_default(endpoint, default) do
    get(endpoint) || default
  end

  def get_all() do
    Agent.get(__MODULE__, &Map.values(&1))
  end

  def has?(endpoint) do
    Agent.get(__MODULE__, &Map.has_key?(&1, endpoint))
  end

  def put(endpoint, %Middleware{} = m) do
    Agent.update(__MODULE__, &Map.put(&1, endpoint, m))
  end

  def put(%Middleware{id: id} = m) do
    case Agent.update(__MODULE__, &Map.put(&1, id, m)) do
      :ok -> {:ok, m}
      {:error, _reason} = err -> err
    end
  end
end
