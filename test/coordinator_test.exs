defmodule CoordinatorTest do
    use ExUnit.Case
  
    test "round up to perfect square shold work" do
      assert Coordinator.initialize_actor_system([2, "line", "gossip"]) ==  {:ok, [0, 2, %{}, 0, 0]}
    end
end