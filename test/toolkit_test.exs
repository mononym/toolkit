defmodule ToolkitTest do
  use ExUnit.Case
  doctest Toolkit

  test "greets the world" do
    assert Toolkit.hello() == :world
  end
end
