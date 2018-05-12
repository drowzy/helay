defmodule HelayClient.TransformTest do
  use ExUnit.Case
  alias HelayClient.Transform

  test "new/1 with a valid string map returns a transform struct" do
    assert %Transform{type: :jq} = Transform.new(%{"type" => "jq"})
  end

  test "new/1 with a keyword list returns a transform struct" do
    assert %Transform{type: :jq} = Transform.new(type: :jq)
  end

  test "new/1 with the type parallel creates Transforms recursivly" do
    opts = %{
      "type" => "parallel",
      "args" => [
        [%{"type" => "jq", "args" => "{foo: .json}"}],
        [%{"type" => "jq", "args" => "{foo: .json}"}]
      ]
    }

    assert %Transform{type: :parallel, args: args} = Transform.new(opts)
    assert length(args) == 2
  end

  test "activate/2 sets the input to the first Transform" do
    input = %{"foo" => "bar"}
    t = Transform.new(type: :jq)

    [h | _t] = Transform.activate([t], input)

    assert h.input == input
  end

  test "activate/2 can handle single values" do
    input = %{"foo" => "bar"}
    t = Transform.new(type: :jq)

    [h | _t] = Transform.activate(t, input)

    assert h.input == input
  end

  test "replace_templates/2 replaces all template strings present in args" do
    base = "http://httpbin.org"

    opts = [
      args: %{method: "POST", uri: "#{base}/<%= method %>"},
      input: %{method: "post"}
    ]

    %Transform{args: args} =
      opts
      |> Transform.new()
      |> Transform.replace_templates()

    assert args.uri == "#{base}/post"
  end

  test "replace_templates/2 does nothing to non template fields" do
    base = "http://httpbin.org"

    opts = [
      args: %{method: "POST", uri: "#{base}"},
      input: %{method: "post"}
    ]

    %Transform{args: args} =
      opts
      |> Transform.new()
      |> Transform.replace_templates()

    assert args.uri == base
  end

  test "replace_templates/2 handles string args" do
    opts = [
      args: "http://httpbin.org/<%= method %>",
      input: %{method: "post"}
    ]

    %Transform{args: args} =
      opts
      |> Transform.new()
      |> Transform.replace_templates()

    assert args == "http://httpbin.org/post"
  end

  describe "apply_to/2" do
    setup do
      transforms = [%Transform{type: :identity}]
      {:ok, ts: transforms, input: "identity"}
    end

    @tag :capture_log
    test "returns {:ok, result} if successful", %{ts: ts, input: input} do
      assert {:ok, output} = Transform.apply_to(ts, input)
      assert output == input
    end

    @tag :capture_log
    test "returns {:error, reason} if not successful", %{input: input} do
      assert {:error, {:not_supported, _}} = Transform.apply_to([%Transform{type: :error}], input)
    end
  end
end
