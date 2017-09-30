defmodule App do
    def main(args) do
        #input = Application.get_env(:project2, :num_of_nodes, 1000, :topology, full_network, :algorithm, gossip)    
        
        ############### add check invalid input if possible ###################
        args |> loop(100) # 100 is set to non-negative number, so that the first loop() is executed
    end

    defp loop(args, n) when n > 0 do
        num_of_nodes = Enum.at(args, 0) |> String.to_integer
        topology = Enum.at(args, 1)
        algorithm = Enum.at(args, 2)

        # for 2D based topology, round up num_of_nodes to a perfect square
        if String.equivalent?(topology, "2D") || String.equivalent?(topology, "imperfect2D") do
            square_root = :math.sqrt(num_of_nodes) |> Float.ceil |> :math.pow(2) |> trunc
        end

        # spawns coordinator
        coordinator = spawn(Coordinator, :initialize_actor_system, [num_of_nodes, topology, algorithm])
        
        # spawns coordinator and workers
        num_of_zeros = args        
        banker = spawn(Banker, :loop, [[],[]])
        for n <- 1..num_of_workers do
            spawn(Worker, :mine, [num_of_zeros, banker])
            #send worker_pid, {:self, coordinator_pid}
        end
        loop(args, n - 1)
    end

    defp loop(args, n) do
        :timer.sleep 1000
        loop(args, n)
    end
    
end