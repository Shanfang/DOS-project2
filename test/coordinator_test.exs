defmodule CoordinatorTest do
    use ExUnit.Case

    test "should init correctly" do
      assert Coordinator.init([]) == {:ok, %Coordinator.State{conv_count: 0, total_nodes: 0, start_time: 0, end_time: 0}}
    end

    test "initialize actor system should work" do
      assert Coordinator.init([]) |> elem(1) |>
        Coordinator.initialize_actor_system([3, "line", "gossip"]) == {:ok, %Coordinator.State{conv_count: 0, total_nodes: 3, start_time: 0, end_time: 0}}
    end 

end