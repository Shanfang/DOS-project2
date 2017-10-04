defmodule CliTest
 do
  use ExUnit.Case
  
    #test "should correctly parse input" do
    #  assert App.main(["--number", 3, "--topology", "full", "--algorithm", "gossip"]) == 3
    #  #assert App.main(["--number", 3, "--topology", "full", "--algorithm", "gossip"]) == "full"      
    #end

    #test "should round up to perfect square" do
    #   assert App.round_up(15) == 16
    #end

    #test "input is a 3-tuple" do
    #  assert App.loop(["--num_of_nodes", 3, "--topology", "full", "--algorithm", "gossip"], 1) == ["--num_of_nodes", 3, "--topology", "full", "--algorithm", "gossip"]
    #end

    #test "parsed input with desired keys" do
      #assert App.main(["--num_of_nodes", 3, "--topology", "full", "--algorithm", "gossip"]) == [num_of_nodes: 3, topology: "full", algorithm: "gossip"]
      #assert App.main([3, "full", "gossip"]) == [num_of_nodes: 3, topology: "full", algorithm: "gossip"]
      
    #end

    test "taking parameters from args without parsing works" do
      #assert App.main(["--num_of_nodes", 3, "--topology", "full", "--algorithm", "gossip"]) == [num_of_nodes: 3, topology: "full", algorithm: "gossip"]
      assert App.main([3, "full", "gossip"]) == 3
      
    end 
end