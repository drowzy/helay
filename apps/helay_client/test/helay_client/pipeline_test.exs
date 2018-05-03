defmodule HelayClient.PipelineTest do
  use ExUnit.Case

  alias HelayClient.{Transform, Pipeline}

  setup do
    transforms = [%Transform{type: :identity}]
    {:ok, ts: transforms, input: "identity"}
  end

  @tag :capture_log
  test "exec/1 returns {:ok, result} if successful", %{ts: ts, input: input} do
    assert {:ok, output} = Pipeline.exec(ts, input)
    assert output == input
  end

  @tag :capture_log
  test "exec/1 returns {:error, reason} if not successful", %{input: input} do
    assert {:error, {:not_supported, _}} = Pipeline.exec([%Transform{type: :error}], input)
  end
end
