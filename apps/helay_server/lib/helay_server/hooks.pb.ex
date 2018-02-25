defmodule Helay.Route do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    provider: String.t
  }
  defstruct [:provider]

  field :provider, 1, type: :string
end

defmodule Helay.Hook do
  use Protobuf, syntax: :proto3

  @type t :: %__MODULE__{
    message: String.t
  }
  defstruct [:message]

  field :message, 1, type: :string
end

defmodule Helay.HelayHook.Service do
  use GRPC.Service, name: "helay.HelayHook"

  rpc :ReceiveHook, Helay.Route, stream(Helay.Hook)
end

defmodule Helay.HelayHook.Stub do
  use GRPC.Stub, service: Helay.HelayHook.Service
end
