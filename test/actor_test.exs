defmodule Project2Test do
    use ExUnit.Case
    doctest Project2
    defmodule State do
        defstruct id: 0, counter: 0, s_value: 0, w_value: 1, unchange_times: 0
    end
    test "should start correctly" do
        assert Actor.start_link(1) == {:ok, :some_pid}
    end

    test "callback of init" do
        assert Actor.init(1) == {:ok, %State{id: 1, counter: 0, s_value: 0, w_value: 1, unchange_times: 0}}
    end 
    
    test "gossip algorithm with line topology" do
        assert Actor.handle_cast({:start_gossip, [num_of_nodes: 3, topology: "line"]}, %State{id: 1, counter: 0, s_value: 0, w_value: 1, unchange_times: 0}) == {:noreply, %State{id: 1, counter: 1, s_value: 0, w_value: 1, unchange_times: 0}}           
    end 
end