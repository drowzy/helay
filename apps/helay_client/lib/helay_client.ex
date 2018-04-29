defmodule HelayClient do
  alias HelayClient.Utils

  def child_spec(mode, conf) when is_binary(mode), do: child_spec(String.to_atom(mode), conf)

  def child_spec(:mixed, %{receiver_port: port}) do
    [
      %{
        id: HelayClient.HttpReceiver,
        start:
          {HttpReceiver, :start_link,
           [
             {HelayClient.Pipeline, :handle, ["foo"]},
             [port: Utils.parse_port(port), url_base: "hook"]
           ]}
      }
    ]
  end
end
