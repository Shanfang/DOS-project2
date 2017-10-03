defmodule Coordinator do
    use GenServer

    ######################### client API ####################
    def start_link do
        GenServer.start_link(__MODULE__, [], [name: {:global, __MODULE__}])
    end

    def initialize_actor_system do 
        GenServer.call({:global, __MODULE__}, {:initialize_actor_system, [num_of_nodes, topology, algorithm]})
    end  
    def converged(:converged) do
        GenServer.cast(@name, :converged)
    end

    ######################### callbacks ####################

    def init([]) do
        conv_count = 0
        actors_mapping = %{}
        start_time = 0
        end_time = 0 
        num_of_nodes = 0      
        {:ok, [conv_count, total_nodes, actors_mapping, start_time, end_time]}
    end
    def handle_call({:initialize_actor_system, [num_of_nodes, topology, algorithm]) do
        total_nodes = num_of_nodes
        actors_mapping = init_actors(num_of_nodes, topology, algorithm)
        {:ok, [conv_count, total_nodes, actors_mapping, start_time, end_time]}
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
        actors = %{}
        list = []
        for index <- 0..num_of_nodes - 1 do
            actor = Actor.start_link(index) 
            actors = Map.put(Integer.to_string(index), actor)
            list = [index | list]
        end 

        initial_actor_id = Enum.random(list)
        # fetch the name of the initial actor from mapping
        initial_actor_name = Map.fetch(actors, Integer(initial_actor_id)


        # start timing when initialization is complete
        start_time = :os.system_time(:millisecond)
        case algorithm do
            "gossip" ->
                # start gossip()
            "push_sum" ->
                # start push_sum()
        end

        #Actor.start_work([num_of_nodes, topology, algorithm, initial_actor_id])
            
            ##########
            # hwo to start a specific worker???????    
            ############
    end

    defp init_actors(num_of_nodes, topology, algorithm) do
        
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
            actor_tuple = {Integer.to_string(id) : actor_pid}
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