defmodule Coordinator do
    use GenServer
    @name COORDINATOR

    ######################### client API ####################
    def start_link([counter, num_of_nodes]) do
        GenServer.start_link(__MODULE__, [counter, num_of_nodes], opts ++ [name: COORDINATOR)
    end

    def converged(:converged) do
        GenServer.cast(@name, :converged)
    end

    ######################### callbacks ####################

    def init([counter, num_of_nodes, topology, algorithm]) do
        # state = init_state()
        initialize_actor_system(num_of_nodes, topology, algorithm)
        {:ok, []}
    end

    def handle_cast(:converged, state) do
        conv_count = conv_count + 1
        if conv_count == num_of_nodes do
            end_time = :os.system_time(:millisecond)
            conv_time = end_time - start_time
            IO.puts "Converged, time taken is: " <> Integer.to_string(conv_time) <> "millseconds"  
        end
        {:noreply, _state}
    end 

    ################## helper functions ####################

    defp initialize_actor_system(num_of_nodes, topology, algorithm) do       
        # building actors system
        for id <- 1..num_of_nodes do
            actor_pid = spawn(Actor, :initialize_actor, [num_of_nodes, topology, i])
            actor_tuple = {Integer.to_string : actor_pid}
            neighbors = [actor_tuple | neighbors]
            #is_alive = [true | is_alive]    
        end 

        # randomly choose an actor as the starting node 
        initial_actor = Enum.random(neighbors)

        # start timing when initialization is complete
        start_time = :os.system_time(:millisecond)

        ############

        #########start the initial_actor ##########
    end

    defp initialize_actor_system(num_of_nodes, topology, algorithm) do
        
        # count the number of actors 
        # (i) who has received the rumor at least once (in the scenario of gossip algorithm)
        # (ii) whose s/w ration has converged
        conv_count = 0

        ##############!!!!!!!!!!!!!!! neighbors should be like [one: "first", two: "second"]
        #### then, need to find how to add a key-value pair to the list###########

       # Map.fetch(neighbors, neighbot_id) => this will return {:ok, neighbot_id}
        # then use elem({:ok, neighbot_id}, 1) to get the pid from the tuple
# now I am working on the genserver branch
        
        neighbors = [{}]
        # is_alive = []
        start_time = 0

        # build topology
        for id <- 1..num_of_nodes do
            actor_pid = spawn(Actor, :initialize_actor, [num_of_nodes, topology, i])
            actor_tuple = {Integer.to_string : actor_pid}
            neighbors = [actor_tuple | neighbors]
            #is_alive = [true | is_alive]    
        end 
        
        # randomly choose an actor as the starting node 
        initial_actor = Enum.random(neighbors)

        case algorithm do
            "gossip" ->
                # start gossip algorithm
                gossip_algorithm(initial_actor, topology)
            "push_sum" ->
                # start the push algorithm
                push_sum_algorithm(initial_actor, topology)
            _ ->
                IO.puts "Invalid algorithm, please try again!"
        end
    end

    defp gossip_algorithm(initial_actor, topology, start_time) do
        # start the gossip protocol
        # start_time = :os.system_time(:millisecond)
        send initial_actor, {:start_gossip, neighbors}
        IO.puts "starting gossip"
        start_time = :os.system_time(:millisecond)        
    end

    defp push_sum_algorithm(initial_actor, topology, start_time) do
        # start the push_sum protocol
        # start_time = :os.system_time(:millisecond)
        send initial_actor, {:start_push_sum, neighbors}
        IO.puts "starting push_sum"
        start_time = :os.system_time(:millisecond)        
    end

    # handle message sent from actors
    def handle_msg do
        receive do
            {:gossip_converge} -> 
                conv_count = conv_count + 1
                if conv_count == num_of_nodes do
                    end_time = :os.system_time(:millisecond)
                    conv_time = end_time - start_time
                    IO.puts "gossip converged: " <> Integer.to_string(conv_time)                    
                end
            {:push_sum_converge, sw_ration} ->
                conv_count = conv_count + 1
                if conv_count == 1 do
                    end_time = :os.system_time(:millisecond)
                    conv_time = end_time - start_time
                    conv_time = end_time - start_time                    
                    IO.puts "push_sum converged: " <> Integer.to_string(conv_time)    
                end
            _ ->
                IO.puts "invalid message from the actor!"
        end
        handle_msg
    end
end