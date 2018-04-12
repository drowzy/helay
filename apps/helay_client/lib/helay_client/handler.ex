defmodule HelayClient.Handler do
  require Logger

  def handle(arg, body) do
    Logger.info("#{__MODULE__} hit with :: #{inspect arg} -> #{inspect body}")
  end

  def dispatch(args) do
    Logger.info("Received dispatch #{args}")
  end
end
