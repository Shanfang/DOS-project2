defmodule Coordinator do
    use GenServer

    ######################### client API ####################
    def start_link do
        GenServer.start_link(__MODULE__, [], [name: :coordinator])
    end

    def initialize_actor_system(coordinator, [num_of_nodes, topology, algorithm]) do 
        GenServer.call(coordinator, {:initialize_actor_system, [num_of_nodes, topology, algorithm]})
    end  
    def converged(coordinator, :converged) do
        GenServer.cast(coordinator, :converged)
    end

    ######################### callbacks ####################

    def init([]) do    
        {:ok, [conv_count: 0, total_nodes: 0, start_time: 0, end_time: 0]}
    end

    def handle_call({:initialize_actor_system, [num_of_nodes, topology, algorithm]}) do
        total_nodes = num_of_nodes
        start_time = init_actors(num_of_nodes, topology, algorithm)
        {:ok, [conv_count: 0, total_nodes: total_nodes, start_time: start_time, end_time: 0]}
    end

    def handle_cast(:converged, state) do
        conv_count = conv_count + 1
        if conv_count == total_nodes do
            end_time = :os.system_time(:millisecond)
            conv_time = end_time - start_time
            IO.puts "Converged, time taken is: " <> Integer.to_string(conv_time) <> "millseconds"  
        end
        {:noreply, _state}
    end 

    ################## helper functions ####################

    defp init_actors(num_of_nodes, topology, algorithm) do       
        # building actors system
        list = []
        for index <- 0..num_of_nodes - 1 do
            actor = Actor.start_link(index)            
            list = [index | list]
        end 

        initial_actor = list |> Enum.random |> Integer.to_string

        # start timing when initialization is complete
        start_time = :os.system_time(:millisecond)
        case algorithm do
            "gossip" ->
                Actor.start_gossip(initial_actor, [num_of_nodes, topology])                
            "push_sum" ->
                Actor.start_push_sum(initial_actor, [num_of_nodes, topology])                
            _ -> 
                IO.puts "Invalid algorithm, please try again!"                   
        end
        start_time
    end