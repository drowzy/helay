defmodule HelayClient.Template do
  def in?(arg) when is_map(arg) or arg == nil, do: false

  def in?(arg) do
    Regex.match?(~r/<%[%=-].*%>/, arg)
  end

  def find_keys(args) do
    args
    |> find()
    |> Enum.map(fn {k, v} -> k end)
  end

  def find(args) do
    args
    |> Enum.filter(fn {k, v} -> in?(v) end)
  end

  def substitue(args, input) when is_binary(args) do
    EEx.eval_string(args, as_keyword(input))
  end

  def substitue(args, input) do
    templetable = as_keyword(input)

    args
    |> find()
    |> Enum.map(fn {k, v} -> {k, EEx.eval_string(v, templetable)} end)
    |> Enum.into(%{})
  end

  defp as_keyword(map) do
    Enum.map(map, fn {k, v} ->
      if Kernel.is_binary(k), do: {String.to_atom(k), v}, else: {k, v}
    end)
  end
end
