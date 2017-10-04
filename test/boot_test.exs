defmodule BootTest do
  use ExUnit.Case
  
  test "initialization of coordinator" do
      assert App.hello() == :world
  end
end