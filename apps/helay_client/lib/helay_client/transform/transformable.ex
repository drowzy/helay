defmodule HelayClient.Transform.Transformable do
  alias HelayClient.Transform

  @callback run(Transform.t()) :: {:ok, Transform.t()} | {:error, term()}
end
