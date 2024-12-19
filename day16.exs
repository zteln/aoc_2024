defmodule Day16 do
  def main(input) do
    {nodes, start_position, end_position} = parse(input)

    IO.puts("Part one result: #{part_one(nodes, start_position, end_position)}")
    IO.puts("Part two result: #{part_two(nodes, start_position, end_position)}")
  end

  defp parse(input) do
    map =
      input
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)
      |> Enum.with_index(fn x, x_idx ->
        Enum.with_index(x, fn y, y_idx -> {{x_idx, y_idx}, y} end)
      end)
      |> List.flatten()
      |> Enum.into(%{})

    {start_position, _} = Enum.find(map, fn {_, c} -> c == "S" end)
    {end_position, _} = Enum.find(map, fn {_, c} -> c == "E" end)

    nodes =
      map
      |> Enum.filter(&(elem(&1, 1) == "."))
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()
      |> MapSet.put(end_position)

    {nodes, start_position, end_position}
  end

  # Dijkstra's algorithm
  defp part_one(nodes, start_position, end_position) do
    visited_nodes = [{0, start_position, {0, 1}}]

    solve(nodes, visited_nodes, :ordsets.new(), end_position)
  end

  defp part_two(nodes, start_position, end_position) do
    visited_nodes = [{0, start_position, {0, 1}}]

    best = solve(nodes, visited_nodes, :ordsets.new(), end_position)

    visited_nodes = MapSet.new([{start_position, {0, 1}}])

    paths = :gb_sets.singleton({0, start_position, {0, 1}, []})

    find_best_paths(nodes, paths, end_position, visited_nodes, best)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.count()
  end

  # Courtesy: https://github.com/bjorng/advent-of-code/blob/main/2024/day16/lib/day16.ex for faster solution
  defp find_best_paths(nodes, paths, goal, visited_nodes, best) do
    case next(paths) do
      nil ->
        []

      {{^best, ^goal, _dir, prevs}, paths} ->
        prevs = [goal | prevs]
        [prevs | find_best_paths(nodes, paths, goal, visited_nodes, best)]

      {{score, _, _, _}, _} when score > best ->
        []

      {{score, cursor, dir, prevs}, paths} ->
        visited_nodes = MapSet.put(visited_nodes, {cursor, dir})

        prevs =
          if List.first(prevs) == cursor do
            prevs
          else
            [cursor | prevs]
          end

        paths =
          adjacent_nodes(nodes, {score, cursor, dir}, fn {x, y}, {dx, dy} ->
            MapSet.member?(visited_nodes, {{x + dx, y + dy}, {dx, dy}})
          end)
          |> Enum.reduce(paths, fn {score, pos, dir}, acc ->
            :gb_sets.add_element({score, pos, dir, prevs}, acc)
          end)

        find_best_paths(nodes, paths, goal, visited_nodes, best)
    end
  end

  defp next(paths) do
    if :gb_sets.is_empty(paths) do
      nil
    else
      :gb_sets.take_smallest(paths)
    end
  end

  defp solve(_nodes, [{distance, cursor, _} | _], _, goal)
       when cursor == goal do
    distance
  end

  defp solve(nodes, [node | prevs] = visited_nodes, adj_nodes, goal) do
    [{_, pos, _} = nearest_adj_node | adj_nodes] =
      adjacent_nodes(nodes, node, fn {x, y}, {dx, dy} ->
        Enum.any?(prevs, fn {_, pos, dir} -> pos == {x, y} and dir == {dx, dy} end)
      end)
      |> Enum.reduce(adj_nodes, &:ordsets.add_element(&1, &2))

    nodes = MapSet.delete(nodes, pos)

    solve(nodes, [nearest_adj_node | visited_nodes], adj_nodes, goal)
  end

  defp adjacent_nodes(nodes, {distance, {x, y}, {dx, dy}}, filter) do
    allowed_movement({dx, dy})
    |> Enum.filter(fn {_d, {dx, dy}} -> MapSet.member?(nodes, {x + dx, y + dy}) end)
    |> Enum.reject(fn {_d, {dx, dy}} ->
      filter.({x, y}, {dx, dy})
    end)
    |> Enum.map(fn
      {1, {dx, dy}} -> {distance + 1, {x + dx, y + dy}, {dx, dy}}
      {d, {dx, dy}} -> {distance + d, {x, y}, {dx, dy}}
    end)
  end

  defp allowed_movement({0, 1}), do: [{1000, {-1, 0}}, {1000, {1, 0}}, {1, {0, 1}}]
  defp allowed_movement({0, -1}), do: [{1000, {-1, 0}}, {1000, {1, 0}}, {1, {0, -1}}]
  defp allowed_movement({1, 0}), do: [{1000, {0, -1}}, {1000, {0, 1}}, {1, {1, 0}}]
  defp allowed_movement({-1, 0}), do: [{1000, {0, -1}}, {1000, {0, 1}}, {1, {-1, 0}}]

  def print_nodes(nodes) do
    lines =
      for x <- 0..14, reduce: "" do
        lines ->
          line =
            for y <- 0..14, reduce: "" do
              line ->
                char =
                  if Enum.find(nodes, fn {node, _} -> node == {x, y} end), do: "x", else: "."

                line <> char
            end

          lines <> line <> "\n"
      end

    Process.sleep(70)
    IO.puts(IO.ANSI.clear())
    IO.puts(lines)
  end
end

System.argv()
|> hd()
|> File.read!()
|> Day16.main()
