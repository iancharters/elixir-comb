defmodule CombTest do
  use ExUnit.Case
  doctest Comb

  test "greets the world" do
    assert Comb.hello() == :world
  end
end
