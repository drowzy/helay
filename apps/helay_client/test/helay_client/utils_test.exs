defmodule HelayClient.UtilsTest do
  use ExUnit.Case

  test "parse_port/1 can parse integers" do
    assert HelayClient.Utils.parse_port(4000) == 4000
  end

  test "parse_port/1 can parse strings" do
    assert HelayClient.Utils.parse_port("4000") == 4000
  end
end
