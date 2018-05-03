defmodule HelayClient.MiddlewareTest do
  use ExUnit.Case
  alias HelayClient.Middleware

  test "new/1 with a valid string map returns a struct" do
    assert %Middleware{endpoint: endpoint} = Middleware.new(%{"endpoint" => "/hook"})
    assert endpoint == "/hook"
  end

  test "new/1 sets an id" do
    assert %Middleware{id: id} = Middleware.new(%{"endpoint" => "/hook"})
    assert Kernel.is_binary(id)
  end

  test "new/1 with a keyword list returns a struct" do
    assert %Middleware{endpoint: "/hook"} = Middleware.new(endpoint: "/hook")
  end
end
