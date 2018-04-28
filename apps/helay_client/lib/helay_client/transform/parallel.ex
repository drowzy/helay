defmodule HelayClient.Transform.Parallel do
  @behaviour HelayClient.Transform.Transformable

  alias HelayClient.{Transform, Pipeline}

  def run(%Transform{type: :parallel, args: args, input: input}) do
    args
    |> Task.async_stream(&Pipeline.exec(&1, input))
    |> Stream.run()
  end
end
