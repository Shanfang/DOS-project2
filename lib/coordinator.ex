defmodule Coordinator do
    use GenServer

    ######################### client API ####################

    def start_link do
        GenServer.start_link(__MODULE__, %{}, [name: :coordinator])
    end

    def initialize_actor_system(coordinator, num_of_nodes, topology, algorithm) do 
        GenServer.cast(coordinator, {:initialize_actor_system, num_of_nodes, topology, algorithm})
    end  
    def converged(coordinator, :converged) do
        GenServer.cast(coordinator, :converged)
    end

    def say_hello(coordinator, :hello) do
        GenServer.cast(coordinator, :hello)
    end
    ######################### callbacks ####################
    def init(%{}) do
        state = %{conv_count: 0, total_nodes: 0, start_time: 0, end_time: 0}
        {:ok, state}
    end

    #def handle_call({:initialize_actor_system, [num_of_nodes: num_of_nodes, topology: topology, algorithm: algorithm]}, _from, state) do        
    def handle_cast({:initialize_actor_system, num_of_nodes, topology, algorithm}, state) do
        start_time = init_actors(num_of_nodes, topology, algorithm)
        IO.puts "actors have been initialized"
        {:noreply, %{state | total_nodes: num_of_nodes, start_time: start_time}}
    end

    def handle_info(:hello, state) do
        IO.put "hello Shanfang"
        {:noreply, state}
    end
    def handle_cast(:converged, state) do
        conv_count = state[:conv_count] + 1
        total_num = state[:total_nodes]
        if conv_count == total_num do
            end_time = :os.system_time(:millisecond)
            conv_time = end_time - state[:start_time]
            IO.puts "Converged, time taken is: " <> Integer.to_string(conv_time) <> "millseconds"  
        else
            end_time = 0
        end
        {:noreply, %{state |conv_count: conv_count, end_time: end_time}}
    end 

    ################## helper functions ####################

    defp init_actors(num_of_nodes, topology, algorithm) do       
        # building actors system

        # num_of_nodes = String.to_integer(num_of_nodes)
        for index <- 0..num_of_nodes - 1 do
            Actor.start_link(index)            
        end 
         
        initial_actor = :rand.uniform(num_of_nodes - 1) |> Integer.to_string |> String.to_atom

        # start timing when initialization is complete
        start_time = :os.system_time(:millisecond)
        case algorithm do
            "gossip" ->
                Actor.start_gossip(initial_actor, num_of_nodes, topology)                
            "push_sum" ->
                Actor.start_push_sum(initial_actor, num_of_nodes, topology, 0, 0.5)                
            _ -> 
                IO.puts "Invalid algorithm, please try again!"                   
        end
        start_time
    end
end