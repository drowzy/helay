defmodule HelayClient.Transform.File do
  @behaviour HelayClient.Transform

  alias HelayClient.Transform

  def run(%Transform{type: :file, args: %{"path" => path}, input: input}) do
    case File.write(path, Poison.encode!(input), [:append]) do
      :ok -> {:ok, %Transform{output: path}}
      error -> error
    end
  end
end
