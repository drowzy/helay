defmodule HelayClient.Middleware do
  alias HelayClient.{Pipeline, Transform, Utils}
  alias HelayClient.Middleware.{WorkerSupervisor, Worker}
  defstruct id: nil, endpoint: nil, transforms: []

  def new(opts) when is_map(opts) do
    __MODULE__
    |> Utils.to_struct(opts)
    |> Map.put(:id, UUID.uuid4())
    |> Map.update!(:transforms, fn ts -> Enum.map(ts, &Transform.new/1) end)
  end

  def new(opts), do: __MODULE__ |> struct(opts) |> Map.put(:id, UUID.uuid4())

  def start(sup, opts) do
    %__MODULE__{transforms: ts, id: id} = middleware = new(opts)

    case WorkerSupervisor.start_proc(sup, id, mfa: {Pipeline, :exec, [ts]}) do
      {:ok, _id} -> {:ok, middleware}
      err -> err
    end
  end

  def exec(id, input) do
    id
    |> WorkerSupervisor.via_tuple()
    |> Worker.exec(input)
  end

  def exec_async(id, input) do
    id
    |> WorkerSupervisor.via_tuple()
    |> Worker.exec_async(input)
  end

  def count(id) do
    id
    |> WorkerSupervisor.via_tuple()
    |> Worker.count()
  end
end
