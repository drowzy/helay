defmodule HelayClient do
  alias HelayClient.Utils

  def child_spec(mode, conf) when is_binary(mode), do: child_spec(String.to_atom(mode), conf)

  def child_spec(:mixed, %{receiver_port: port}) do
    [

    ]
  end
end
