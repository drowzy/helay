defmodule HelayClient.TemplateTest do
  use ExUnit.Case
  alias HelayClient.Template

  test "in?/1 returns true when using <%= template" do
    assert Template.in?("<%= foo %>")
  end

  test "in?/1 returns true when using <%% template" do
    assert Template.in?("<%% foo %>")
  end

  test "in?/1 returns true when using <%- template" do
    assert Template.in?("<%- foo %>")
  end

  test "in?/1 returns true when using <% template" do
    assert Template.in?("<%- foo %>")
  end

  test "in?/1 templates can be anywhere in the string" do
    assert Template.in?("foo <%= foo %> foo")
  end

  test "in?/1 incomplete or faulty strings return false" do
    refute Template.in?("<%= foo >")
  end

  test "in?/1 handles multiline statements" do
    expr = """
    <%= if true do %>
    foo
    <% else %>
    bar
    """
    assert Template.in?(expr)
  end

  test "find_keys/1 extracts map keys which contain templates" do
    assert Template.find_keys(%{foo: "<%= foo %>", bar: "foo"}) == [:foo]
    assert Template.find_keys(%{foo: "<%% foo %>", bar: "foo"}) == [:foo]
    assert Template.find_keys(%{foo: "< foo %>"}) == []
  end

  test "substitue/2 replaces applicable template values" do
    assert %{foo: "foo"} == Template.substitue(%{foo: "<%= foo %>"}, %{foo: "foo"})
    assert %{uri: "http://httpbin.org/post"} == Template.substitue(%{uri: "http://httpbin.org/<%= method %>"}, %{method: "post"})
  end

  test "substitue/2 can handle string maps" do
    assert %{foo: "foo"} == Template.substitue(%{foo: "<%= foo %>"}, %{"foo" => "foo"})
  end
end
