defmodule Day12 do
  def main(input) do
    farm = parse(input)

    IO.puts("Part one result: #{part_one(farm)}")
    IO.puts("Part two result: #{part_two(farm)}")
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.to_charlist/1)
    |> Enum.with_index(fn x, x_idx ->
      Enum.with_index(x, fn y, y_idx ->
        {{x_idx, y_idx}, y}
      end)
    end)
    |> List.flatten()
    |> Enum.into(%{})
    |> Enum.group_by(&elem(&1, 1), &elem(&1, 0))
  end

  defp part_one(farm) do
    farm
    |> Enum.flat_map(fn {_plant, coords} ->
      find_clusters(coords)
    end)
    |> Enum.map(fn plot ->
      perimeter(plot) * area(plot)
    end)
    |> Enum.sum()
  end

  defp part_two(farm) do
    farm
    |> Enum.flat_map(fn {_plant, coords} ->
      find_clusters(coords)
    end)
    |> Enum.map(fn plot ->
      sides(plot) * area(plot)
    end)
    |> Enum.sum()
  end

  defp find_clusters(coords, clusters \\ [])
  defp find_clusters([], clusters), do: clusters

  defp find_clusters(coords, clusters) do
    {coords, cluster} = find_cluster(coords, [])
    find_clusters(coords, [cluster | clusters])
  end

  defp find_cluster([coord | coords], []) do
    find_cluster(coords, [coord])
  end

  defp find_cluster(coords, cluster) do
    Enum.reduce(coords, {[], []}, fn coord, {neighbours, coords} ->
      if Enum.any?(cluster, fn cluster_coord -> is_neighbour(coord, cluster_coord) end) do
        {[coord | neighbours], coords}
      else
        {neighbours, [coord | coords]}
      end
    end)
    |> case do
      {[], coords} -> {coords, cluster}
      {neighbours, coords} -> find_cluster(coords, neighbours ++ cluster)
    end
  end

  defp perimeter(coords) do
    Enum.map(coords, fn coord ->
      4 - Enum.count(coords, &is_neighbour(&1, coord))
    end)
    |> Enum.sum()
  end

  defp area(plot), do: length(plot)

  defp sides(plot) do
    Enum.reduce(plot, [], fn coord, sides ->
      fences =
        Enum.map(dirs(), &fence_dir(coord, &1, plot))
        |> Enum.reject(&is_nil/1)

      [fences | sides]
    end)
    |> List.flatten()
    |> MapSet.new()
    |> traverse_sides(0)
  end

  defp traverse_sides(fences, sides_count) do
    if MapSet.size(fences) == 0 do
      sides_count
    else
      fences
      |> traverse_fence(Enum.min(fences))
      |> traverse_sides(sides_count + 1)
    end
  end

  defp traverse_fence(fences, entry) do
    if not MapSet.member?(fences, entry) do
      fences
    else
      fences = MapSet.delete(fences, entry)

      case entry do
        {{x, y}, dir} when dir == :up or dir == :down ->
          traverse_fence(fences, {{x, y + 1}, dir})

        {{x, y}, dir} when dir == :left or dir == :right ->
          traverse_fence(fences, {{x + 1, y}, dir})
      end
    end
  end

  defp fence_dir({x, y}, {dx, dy}, plot) do
    if {x + dx, y + dy} not in plot do
      {{x, y}, get_dir({dx, dy})}
    else
      nil
    end
  end

  defp get_dir({-1, 0}), do: :up
  defp get_dir({1, 0}), do: :down
  defp get_dir({0, 1}), do: :right
  defp get_dir({0, -1}), do: :left

  defp is_neighbour(p1, p2) do
    Enum.any?(dirs(), &neighbour(p1, p2, &1))
  end

  defp neighbour({x1, y1}, {x2, y2}, {dx, dy}), do: {x1, y1} == {x2 + dx, y2 + dy}

  defp dirs, do: [{1, 0}, {-1, 0}, {0, 1}, {0, -1}]
end

System.argv()
|> hd()
|> File.read!()
|> Day12.main()
