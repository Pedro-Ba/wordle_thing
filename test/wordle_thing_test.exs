defmodule WordleThingTest do
  use ExUnit.Case
  doctest WordleThing

  test "greets the world" do
    assert WordleThing.hello() == :world
  end
end
