defmodule HelayClient.Middleware.Worker do
  use GenServer
  require Logger

  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts, opts)
  end

  def init(_opts) do
    {:ok, %{}}
  end
end
