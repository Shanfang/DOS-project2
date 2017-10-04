defmodule App do
    def main(args) do
        num_of_nodes = args[0] |> String.to_integer
        topology = args[1]
        algorithm = args[2]

        #num_of_nodes = args |> OptionParser.parse(strict: [num_of_nodes: :integer]) |> elem(0) |>  Keyword.get(:num_of_nodes)      
        #topology = args |> OptionParser.parse(switches: [topology: :string]) |> elem(0)|>  Keyword.get(:topology)     
        #algorithm = args |> OptionParser.parse(switches: [algorithm: :string]) |> elem(0)|>  Keyword.get(:algorithm)       
        #parsed =     
             # args |> OptionParser.parse |> elem(1)       

       # input = ["num_of_nodes": 100, "topology": "line", "algorithm": "gossip"]
       # Keyword.put(input, :num_of_nodes, Keyword.get(parsed, :num_of_nodes))
        #Keyword.put(input, :topology, Keyword.get(parsed, :topology))
        #Keyword.put(input, :algorithm, Keyword.get(parsed, :algorithm))
        IO.puts num_of_nodes
        IO.puts topology
        IO.puts algorithm
        
        input = [num_of_nodes: 100, topology: "line", algorithm: "gossip"]
        #Keyword.put(input, :num_of_nodes, String.to_integer(args[0]))
        #Keyword.put(input, :topology, args[1])
        #Keyword.put(input, :algorithm, args[2])        
        loop(num_of_nodes, topology, algorithm, 1)
        #input
    end

    #def loop(input, n) when n > 0 do
    def loop(num_of_nodes, topology, algorithm, n) when n > 0 do            

        # for 2D based topology, round up num_of_nodes to a perfect square
        if topology == "2D" || topology == "imperfect2D" do
            
            num_of_nodes = :math.sqrt(num_of_nodes) |> Float.ceil |> :math.pow(2)
            # Keyword.put(input, num_of_nodes, perfect_square)
            IO.puts "round up to perfect square"
        end

        IO.puts "starting coordinator from app..."
        #Coordinator.start_link
        #Coordinator.initialize_actor_system(:coordinator, num_of_nodes, topology, algorithm)        
        #loop(num_of_nodes, topology, algorithm, n - 1)
        num_of_nodes
    end

    def loop(num_of_nodes, topology, algorithm, n) do
        :timer.sleep 1000
        loop(num_of_nodes, topology, algorithm, n)
    end
    
    #def round_up(num) do
    #    num = :math.sqrt(num) |> Float.ceil |> :math.pow(2) 
    #    num       
    #end
end