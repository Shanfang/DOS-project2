defmodule Actor do
    import Topology

    use GenServer

    ######################### client API ####################
    def start_link(index) do
        actor_name = Integer.to_string(index)
        GenServer.start_link(__MODULE__, index, [name: :actor_name])
    end

    def start_gossip(actor_name, [num_of_nodes, topology, id]) do
       GenServer.call(actor_name, {:start_gossip, [num_of_nodes, topology, id]})     
    end

    def start_push_sum(actor_name, [num_of_nodes, topology, id]) do
        GenServer.call(actor_name, {:start_push_sum, [num_of_nodes, topology, id]})             
    end
    
    def gossip_rumor(actor_name) do
        GenServer.call(actor_name, :gossip_rumor)
    end
    def push_sum_rumor(actor_name, [delta_s, delta_w]) do
        GenServer.call(actor_name, {:push_sum_rumor, [delta_s, delta_w]})
    end

    ######################### callbacks ####################

    def init(index) do
        {:ok, [id: index, counter: 0, s_value: 0, w_value: 1, unchange_times: 0]}
    end

    # send rumor to its neighbors, choose neighbor according to topology matching
    def handle_call({:start_gossip, [num_of_nodes, topology, id]}, _from, [id: index, counter: 0, s_value: 0, w_value: 1, unchange_times: 0]) do
        case topology do
            "full" ->
                neighbors = neighbor_full(id, num_of_nodes)
                propagate_gossip(neighbors)
            "2D" ->
                neighbors = neighbor_2D(id, num_of_nodes)
                propagate_gossip(neighbors)
            "line" ->
                neighbors = neighbor_line(id, num_of_nodes)
                propagate_gossip(neighbors)
            "imp2D" ->
                neighbors = neighbor_imp2D(id, num_of_nodes)
                propagate_gossip(neighbors)
            _ ->
                IO.puts "Invalid topology, please try again!"
        end
        new_state = [id: index, counter: 1, s_value: 0, w_value: 1, unchange_times: 0]
        {:ok, new_state}
    end

    def handle_call({:start_push_sum, [num_of_nodes, topology, id]}, _from, [id: index, counter: 0, s_value: 0, w_value: 1, unchange_times: 0]) do
        case topology do
            "full" ->
                neighbor_id = neighbor_full(id, num_of_nodes)
                propagate_push_sum(neighbors, s_value, w_value)
            "2D" ->
                neighbor_id = neighbor_2D(id, num_of_nodes)
                propagate_push_sum(neighbors, neighbor_id)                        
            "line" ->
                neighbor_id = neighbor_line(id, num_of_nodes)
                propagate_push_sum(neighbors, neighbor_id)                        
            "imp2D" ->
                neighbor_id = neighbor_imp2D(id, num_of_nodes)
                propagate_push_sum(neighbors, neighbor_id) 
            _ ->
                IO.puts "Invalid topology, please try again!"
        end
        new_state = [id: index, counter: 1, s_value: id / 2, w_value: 1 / 2, unchange_times: 0]
        {:ok, new_state}        
    end

    
    # process rumor for the push_sum algorithm
    def handle_cast({:push_sum_rumor,[delta_s, delta_w]}, [id: index, counter: counter, s_value: s, w_value: w, unchange_times: unchange]) do
        previous_ration = s / w
        new_s = s + delta_s
        new_w = w + delta_w
        current_ration = new_s / new_w
        new_counter = counter + 1
        unchange = check_unchange(current_ration, previous_ration, unchange)
        if unchange == 3 do
            Coordinator.converged(coordinator, :converged)
            Process.exit(self, :kill)                    
        end 
        {:noreply, [id: index, counter: new_counter, new_s: s, w_value: new_w, unchange_times: unchange]}
    end 

    # process rumor for the gossip algorithm, and if a actor gets 10 messages, it will be killed
    def handle_cast({:gossip_rumor}, state) do
        new_counter = counter + 1
        if new_counter == 10 do
            Coordinator.converged(coordinator, :converged)
            Process.exit(self, :kill)                    
        end
        {:noreply, _state}
    end 

    ######################### helper functions ####################

    # propagate gossip by sending it to neighbors
    defp propagate_gossip(neighbors) do
        Enum.each(neighbors, fn neighbor -> 
            Actor.gossip_rumor(Integer.to_string(neighbor)) 
        end)        
        #if alive?(neighbor_pid) do
        #    Enum.each(neighbors, fn neighbor -> Actor.gossip_rumor(Integer.to_string(neighbor)) end)        
        #end    
    end

    defp propagate_push_sum(neighbors, s_value, w_value) do
        Enum.each(neighbors, fn neighbor -> 
            Actor.gossip_rumor(Integer.to_string(neighbor), [s_value / 2, w_value / 2]) 
        end)                
    end

    defp check_unchange(current_ration, previous_ration, unchange_times) do
        if abs(current_ration - previous_ration) < :math.pow(10, -10) do
            unchange_times = unchange_times + 1
        else 
            unchange_times = 0
        end
        unchange_times
    end
    
end