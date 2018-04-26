defmodule HelayClient.Template do
  def in?(arg) do
    # Regex.match?(~r/<%{1,2}=?.*%>/, arg)
    Regex.match?(~r/<%(%+|=+|-+).*%>/, arg)
  end

  def find_keys(args) do
    args
    |> Enum.filter(fn {k, v} -> in?(v) end)
    |> Enum.map(fn {k, v} -> k end)
  end
end
