defmodule TopologyTest do
    use ExUnit.Case
    
    test "generate full topology neighbors" do
        assert Topology.neighbor_full(0, 9) == [0,1,2,3,4,5,6,7,8]
    end
    test "generate 2D topology neighbors" do
        assert Topology.neighbor_2D(4, 9) == [5, 3, 7, 1]
    end
    test "generate line topology neighbors" do
        assert Topology.neighbor_line(4, 9) == [3,5]
    end
    test "generate line topology neighbors left side" do
        assert Topology.neighbor_line(0, 9) == [1]
    end
    test "generate line topology neighbors right side" do
        assert Topology.neighbor_line(8, 9) == [7]
    end
    test "generate a random neighbor from imp2D topology neighbors" do
        assert Topology.neighbor_imp2D(4, 9) == [5, 3, 7, 1]
    end
  end