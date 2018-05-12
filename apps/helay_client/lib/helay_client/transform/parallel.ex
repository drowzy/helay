defmodule HelayClient.Transform.Parallel do
  @behaviour HelayClient.Transform.Transformable

  alias HelayClient.Transform

  def run(%Transform{type: :parallel, args: args, input: input}) do
    # TODO
    output =
      args
      |> Task.async_stream(&Transform.apply_to(&1, input))
      |> Enum.reduce([], fn {_status, result}, acc -> [result | acc] end)
      |> Enum.reverse()

    {:ok, %Transform{output: output}}
  end
end
