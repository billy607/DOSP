defmodule TtTest do
  use ExUnit.Case
  doctest Tt

  test "greets the world" do
    assert Tt.hello() == :world
  end
end
