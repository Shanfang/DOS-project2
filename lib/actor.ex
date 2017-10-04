defmodule Actor do
    import Topology

    use GenServer

    ######################### client API ####################
    defmodule State do
        defstruct id: 0, counter: 0, s_value: 0, w_value: 1, unchange_times: 0
    end

    def start_link(index) do
        actor_name = index |> Integer.to_string |> String.to_atom
        GenServer.start_link(__MODULE__, index, [name: actor_name])
    end

    def start_gossip(actor_name, [num_of_nodes: num_of_nodes, topology: topology]) do
       GenServer.cast(actor_name, {:start_gossip, [num_of_nodes: num_of_nodes, topology: topology]})     
    end

    def start_push_sum(actor_name, [num_of_nodes: num_of_nodes, topology: topology, delta_s: delta_s, delta_w: delta_w]) do
        GenServer.cast(actor_name, {:start_push_sum, [num_of_nodes: num_of_nodes, topology: topology, delta_s: delta_s, delta_w: delta_w]})             
    end
    
    ######################### callbacks ####################

    def init(index) do
        id = index
        counter = 0
        s_value = 0 
        w_value = 1
        unchange_times = 0
        init([], %State{id: id, counter: counter, s_value: s_value, w_value: w_value, unchange_times: unchange_times})
      end
    
      def init([], state) do
        {:ok, state}
      end

    # send rumor to its neighbors, choose neighbor according to topology matching
    # def handle_call({:start_gossip, [num_of_nodes, topology, id]}, _from, [id: index, counter: 0, s_value: 0, w_value: 1, unchange_times: 0]) do        
    def handle_cast({:start_gossip, [num_of_nodes: num_of_nodes, topology: topology]}, state) do
        IO.puts "start gossip, counter increase by one"
        new_counter = state[:counter] + 1
        if new_counter == 10 do
            Coordinator.converged(:coordinator, :converged)
            Process.exit(self(), :kill)                    
        end 

        case topology do
            "full" ->
                neighbors = Topology.neighbor_full(state[:id], num_of_nodes)
                propagate_gossip(neighbors, num_of_nodes, topology)
            "2D" ->
                neighbors = Topology.neighbor_2D(state[:id], num_of_nodes)
                propagate_gossip(neighbors, num_of_nodes, topology)
            "line" ->
                neighbors = Topology.neighbor_line(state[:id], num_of_nodes)
                propagate_gossip(neighbors, num_of_nodes, topology)
            "imp2D" ->
                neighbors = Topology.neighbor_imp2D(state[:id], num_of_nodes)
                propagate_gossip(neighbors, num_of_nodes, topology)
            _ ->
                IO.puts "Invalid topology, please try again!"
        end
        {:noreply, %{state | counter: new_counter}}
    end

    # when receiving push_sum msg
    def handle_cast({:start_push_sum, [num_of_nodes: num_of_nodes, topology: topology, delta_s: delta_s, delta_w: delta_w]}, state) do
        previous_ration = state[:s_value] / state[:w_value]
        new_s = state[:s_value] + delta_s
        new_w = state[:w_value] + delta_w
        current_ration = new_s / new_w
        new_counter = state[:counter] + 1
        unchange_times = check_unchange(current_ration, previous_ration, :unchange_times)
        if unchange_times == 3 do
            Coordinator.converged(:coordinator, :converged)
            Process.exit(self(), :kill)                    
        end 
  
        case topology do
            "full" ->
                neighbors = Topology.neighbor_full(state[:id], num_of_nodes)
                # propagate_push_sum(neighbors, state)
                propagate_push_sum(neighbors, num_of_nodes, topology, new_s / 2, new_w / 2)
            "2D" ->
                neighbors = Topology.neighbor_2D(state[:id], num_of_nodes)
                propagate_push_sum(neighbors, num_of_nodes, topology, new_s / 2, new_w / 2)
            "line" ->
                neighbors = Topology.neighbor_line(state[:id], num_of_nodes)
                propagate_push_sum(neighbors, num_of_nodes, topology, new_s / 2, new_w / 2)
            "imp2D" ->
                neighbors = Topology.neighbor_imp2D(state[:id], num_of_nodes)
                propagate_push_sum(neighbors, num_of_nodes, topology, new_s / 2, new_w / 2)
            _ ->
                IO.puts "Invalid topology, please try again!"
        end
        s_value = new_s / 2
        w_value = new_w / 2
        {:noreply, %{state | counter: new_counter, s_value: s_value, w_value: w_value, unchange_times: unchange_times}}
    end

    ######################### helper functions ####################


    # propagate gossip by sending it to neighbors
    defp propagate_gossip(neighbors, num_of_nodes, topology) do
        Enum.each(neighbors, fn(neighbor) -> 
            # Actor.gossip_rumor(Integer.to_string(neighbor))
            Actor.start_gossip(Integer.to_string(neighbor), [num_of_nodes, topology])                            
        end)        
        #if alive?(neighbor_pid) do
        #    Enum.each(neighbors, fn neighbor -> Actor.gossip_rumor(Integer.to_string(neighbor)) end)        
        #end    
    end

    defp propagate_push_sum(neighbors, num_of_nodes, topology, delta_s, delta_w) do
        Enum.each(neighbors, fn(neighbor) -> 
            # Actor.gossip_rumor(Integer.to_string(neighbor), [s_value / 2, w_value / 2])
            Actor.start_push_sum(Integer.to_string(neighbor), [num_of_nodes, topology, delta_s, delta_w])                            
        end)                
    end

    defp check_unchange(current_ration, previous_ration, unchange_times) do
        unchange = 
            case abs(current_ration - previous_ration) < :math.pow(10, -10) do
                true ->
                    unchange = unchange_times + 1
                _ ->
                    unchange = 0
            end
        unchange
    end

end