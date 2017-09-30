defmodule Actor do
    msg_received = 0
    s_value = 0
    w_value = 1
    pre_ratio = 0
    id = 0
    neighbors = []
    topology = ""
    algorithm = ""
    def initialize_actor(num_of_nodes, topo, ID) do
        s_value = id
        id = ID
        topology = topo
    end

    defp handle_msg do
        receive do
            # start of gossip protocol
            {:start_gossip, actors} ->
                algorithm = "gossip"
                neighbors = actors
                msg_received = msg_received + 1
                send self, :tell_neighbor                   
                
                if msg_received == 1 do
                    send coordinator, :gossip_converge
                end

                if msg_received == 10 do
                    Process.exit(self, :kill)                    
                end 

            {:gossip_neighbor} ->
                # propograte the rumor
                case topology do
                    "full" ->
                        neighbor_id = neighbor_full(id, num_of_nodes)
                        propgrate_gossip(neighbors, neighbor_id)
                    "2D" ->
                        neighbor_id = neighbor_2D(id, num_of_nodes)
                        propgrate_gossip(neighbors, neighbor_id)                        
                    "line" ->
                        neighbor_id = neighbor_line(id, num_of_nodes)
                        propgrate_gossip(neighbors, neighbor_id)                        
                    "imp2D" ->
                        neighbor_id = neighbor_imp2D(id, num_of_nodes)
                        propgrate_gossip(neighbors, neighbor_id)                        
                end
            # end of gossip protocol

            # start of push sum protocol
            {:start_push_sum, actors} ->
                algorith = "push_sum"
                neighbors = actors
            {:push_sum_neighbor} ->
                # propograte the rumor
                case topology do
                    "full" ->
                        neighbor_id = neighbor_full(id, num_of_nodes)
                        propgrate_push_sum(neighbors, neighbor_id)
                    "2D" ->
                        neighbor_id = neighbor_2D(id, num_of_nodes)
                        propgrate_push_sum(neighbors, neighbor_id)                        
                    "line" ->
                        neighbor_id = neighbor_line(id, num_of_nodes)
                        propgrate_push_sum(neighbors, neighbor_id)                        
                    "imp2D" ->
                        neighbor_id = neighbor_imp2D(id, num_of_nodes)
                        propgrate_push_sum(neighbors, neighbor_id)                        
                end

        end
        handle_msg
    end

    defp propgrate_gossip(neighbors, neighbor_id) do
        # neighbor_pid = Enum.find_value(neighbors, fn ({id, pid}) when neighbor_id == id -> pid end)
        neighbor_pid = List.keyfind(neighbors, neighbor_id, 0) |> elem(1)
        if alive?(neighbor_pid) do
            send neighbor_pid, :start_gossip
        end    
    end

    defp propgrate_push_sum(neighbors, neighbor_id) do
        neighbor_pid = Enum.find_value(neighbors, fn ({id, pid}) when neighbor_id == id -> pid end)
        if alive?(neighbor_pid) do
            send neighbor_pid, :start_push_sum
        end    
    end
end