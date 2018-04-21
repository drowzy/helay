defmodule HelayClient.Middleware do
  alias HelayClient.Transform
  defstruct endpoint: nil, transforms: nil

  def new(%{"endpoint" => endpoint, "transforms" => transforms} = m) do
    %__MODULE__{
      endpoint: endpoint,
      transforms: Enum.map(transforms, &Transform.new/1)
    }
  end

  def new(opts), do: struct(__MODULE__, opts)
end
