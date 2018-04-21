defmodule HelayClient.Transform.File do
  @behaviour HelayClient.Transform

  alias HelayClient.Transform

  def run(%Transform{type: :file, args: %{"path" => path}, input: input}),
    do: File.write(path, Poison.encode!(input), [:binary])
end
