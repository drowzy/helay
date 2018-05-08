defmodule HelayClient.Transform.Identity do
  @behaviour HelayClient.Transform.Transformable
  require Logger

  alias HelayClient.Transform

  def run(%Transform{args: args, input: input}) do
    Logger.info(fn -> "Passthrough on #{args} transform input: #{inspect(input)}" end)
    {:ok, %Transform{output: input}}
  end
end
