defmodule HelayClient.Transform.Jq do
  @behaviour HelayClient.Transform

  alias HelayClient.Transform
  alias Porcelain.Result

  def run(%Transform{args: args, input: input}) do
    case Porcelain.shell("echo '#{encode(input)}' | jq #{args}") do
      %Result{out: output, status: 0} -> {:ok, %Transform{output: decode(output)}}
      %Result{out: output, status: _} -> {:error, output}
    end
  end

  defp decode(json), do: Poison.decode!(json)
  defp encode(input) when is_binary(input), do: input
  defp encode(input), do: Poison.encode!(input)
end
