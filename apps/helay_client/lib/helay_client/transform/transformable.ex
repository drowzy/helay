defmodule HelayClient.Transform.Transformable do
  alias HealyClient.Transform

  @callback run(Transform.t()) :: {:ok, Transform.t()} | {:error, term()}
end
