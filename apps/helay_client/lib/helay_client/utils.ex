defmodule HelayClient.Utils do
  def parse_port(port) when is_integer(port), do: port
  def parse_port(port), do: String.to_integer(port)

  def has_content_type?(headers, content_type) do
    Enum.any?(headers, fn {type, value} ->
      String.downcase(type) == "content-type" and String.downcase(value) == content_type
    end)
  end

  # https://stackoverflow.com/questions/30927635/in-elixir-how-do-you-initialize-a-struct-with-a-map-variable
  def to_struct(kind, attrs) do
    struct = struct(kind)

    Enum.reduce(Map.to_list(struct), struct, fn {k, _}, acc ->
      case Map.fetch(attrs, Atom.to_string(k)) do
        {:ok, v} -> %{acc | k => v}
        :error -> acc
      end
    end)
  end
end
