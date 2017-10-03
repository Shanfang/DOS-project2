defmodule Actor do
    use GenServer
    @name ACTOR

    ######################### client API ####################
    def start_link(counter, s_value, w_value) do
        GenServer.start_link(__MODULE__, [counter, s_value, w_value], opts ++ [name: ACTOR)
    end

    def start_work([num_of_nodes, topology, algorithm, id]) do
        GenServer.call(@name, {:start_work, [num_of_nodes, topology, algorithm, id]})
    end

    def get_rumor(:rumor) do
        GenServer.call(@name, :get_rumor)
    end
    def push_sum_rumor([delta_s, delta_w]) do
        GenServer.call(@name, {:push_sum_rumor, [delta_s, delta_w]})
    end
    ######################### callbacks ####################

    def init([counter, s_value, w_value]) do
        {:ok, [counter : 0, s_value: 0, w_value: 1]}
    end

    # send rumor to its neighbors, choose neighbor according to topo config
    def handle_call({:start_work, [num_of_nodes, topology, algorithm, id]}, _from, state) do
        case algorithm do
            "gossip" -> 
                case topology do
                    "full" ->
                        neighbor_id = neighbor_full(id, num_of_nodes)
                        propagate_gossip(neighbors, neighbor_id)
                    "2D" ->
                        neighbor_id = neighbor_2D(id, num_of_nodes)
                        propagate_gossip(neighbors, neighbor_id)                        
                    "line" ->
                        neighbor_id = neighbor_line(id, num_of_nodes)
                        propagate_gossip(neighbors, neighbor_id)                        
                    "imp2D" ->
                        neighbor_id = neighbor_imp2D(id, num_of_nodes)
                        propagate_gossip(neighbors, neighbor_id)        
                    _ ->
                        IO.puts "Invalid topology, please try again!"
                end
                new_state = [counter: 1, s_value: 0, w_value: 1]
            "push_sum" ->
                case topology do
                    "full" ->
                        neighbor_id = neighbor_full(id, num_of_nodes)
                        propagate_push_sum(neighbors, neighbor_id)
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
                new_state = [counter: 1, s_value: id, w_value: 1]
            _ ->
                IO.puts "Invalid algorithm, please try again!"
                #{:error}
        end
        {:ok, new_state}
    end

    # process rumor for the push_sum algorithm
    def handle_cast({:get_rumor,[delta_s, delta_w]}, state) do

    ########## s_value, w_value, previous_ration, unchange_times are all in the state ###########
        previous_ration = s_value / w_value
        s_value = s_value + delta_s
        w_value = w_value + delta_w
        currentValue = s_value / w_value
        if check_unchange(current_ration, previous_ration, unchange_times) == 3 do
            #send coordinator, :push_sum_converge
            Coordinator.converged(:converged)
            Process.exit(self, :kill)                    
        end 
        {:noreply, _state}
    end 

    # process rumor for the gossip algorithm, and if a actor gets 10 messages, it will be killed
    def handle_cast({:get_rumor}, state) do
        new_counter = counter + 1
        if new_counter == 10 do
            Coordinator.converged(:converged)
            #send coordinator, :gossip_converge
            Process.exit(self, :kill)                    
        end
        {:noreply, _state}
    end 

    ################## helper functions ###################

    # find neighbor for full topology
    defp neighbor_full(id, num_of_nodes) do
        neighbors = []
        for i <- 1..num_of_nodes do
            neighbors = [i | neighbors]
        end
        Enum.filter(neighbors, fn(x) -> x != id end)
        neighbors
    end

    # find neighbor for 2D topology
    defp neighbor_2D(id, num_of_nodes) do
        neighbors = []
        square_len = :math.sqrt(num_of_nodes)
        row_index = id / square_len
        col_index = id % square_len
        if row_index - 1 >= 0 do
            neighbor_up = (row_index - 1) * square_len + col_index
            neighbors = [neighbor_up | neighbors]
        end
        
        if row_index + 1 <= square_len - 1 do
            neighbor_down = (row_index + 1) * square_len + col_index
            neighbors = [neighbor_down | neighbors]
        end

        if col_index - 1 >= 0 do
            neighbor_left = id - 1
            neighbors = [neighbor_left | neighbors]
        end

        if col_index + 1 <= square_len - 1 do
            neighbor_right = id + 1
            neighbors = [neighbor_right | neighbors]
        end
        neighbors
    end

    # find neighbor for line topology
    defp neighbor_line(id, num_of_nodes) do
        neighbors = []
        case id do
            num_of_nodes - 1 ->
                neighbors = [id - 1 | neighbors]
            0 ->
                neighbors = [id + 1 | neighbors]
            _ ->
                neighbors = [id + 1 | neighbors]
                neighbors = [id - 1 | neighbors]
        end
        neighbors
    end

    # find neighbor for imperfect 2D topology
    defp neighbor_imp2D(id, num_of_nodes) do
        neighbors = neighbor_2D(id, num_of_nodes)

        # add a random neighbor
        random_neighbor = :rand.uniform(num_of_nodes) - 1
        neighbors = [random_neighbor | neighbors]
    end

    # propagate gossip by sending it to neighbors
    defp propagate_gossip(neighbors, neighbor_id) do
        # neighbor_pid = Enum.find_value(neighbors, fn ({id, pid}) when neighbor_id == id -> pid end)
        neighbor_pid = List.keyfind(neighbors, neighbor_id, 0) |> elem(1)
        if alive?(neighbor_pid) do
            send neighbor_pid, :rumor
        end    
    end

    defp propagate_push_sum(neighbors, neighbor_id, s_value, w_value) do
        neighbor_pid = Enum.find_value(neighbors, fn ({id, pid}) when neighbor_id == id -> pid end)
        if alive?(neighbor_pid) do
            # neighbors is a map, each os which is a tuple {id, pid_name} 
            # pid_name is created when initializing an actor

            # fetch the neighbor by its id, then call the get_rumor() of that pid_name
            # so there is no need to send it a msg directly, the GenServer handles it for us
            ##########send neighbor_pid, {:push_sum_rumor, [s_value / 2, w_value / 2]}

        end    
    end

    defp check_unchange(current_ration, previous_ration, unchange_times) do
        if abs(current_ration - previous_ration) < 1e-10 do
            unchange_times = unchange_times + 1
        else 
            unchange_times = 0
        end
        unchange_times
    end
end