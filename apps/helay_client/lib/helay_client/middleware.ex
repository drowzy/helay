defmodule HelayClient.Middleware do
  alias HelayClient.{Transform, Utils}
  defstruct id: nil, endpoint: nil, transforms: []

  def new(opts) when is_map(opts) do
    __MODULE__
    |> Utils.to_struct(opts)
    |> Map.put(:id, UUID.uuid4())
    |> Map.update!(:transforms, fn ts -> Enum.map(ts, &Transform.new/1) end)
  end

  def new(opts), do: __MODULE__ |> struct(opts) |> Map.put(:id, UUID.uuid4())
end
