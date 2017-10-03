defmodule Topology do

    # find neighbors for full topology
    defp neighbor_full(id, num_of_nodes) do
        neighbors = []
        for i <- 1..num_of_nodes do
            neighbors = [i | neighbors]
        end
        Enum.filter(neighbors, fn(x) -> x != id end)
        neighbors
    end

    # find neighbors for 2D topology
    defp neighbor_2D(id, num_of_nodes) do
        neighbors = []
        square_len = :math.sqrt(num_of_nodes)
        row_index = div(id, square_len)
        col_index = rem(id, square_len)
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

    # find neighbors for line topology
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

    # find neighbors for imperfect 2D topology
    defp neighbor_imp2D(id, num_of_nodes) do
        neighbors = neighbor_2D(id, num_of_nodes)
        random_neighbor = :rand.uniform(num_of_nodes) - 1
        neighbors = [random_neighbor | neighbors]
    end
end