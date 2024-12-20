defmodule Day18 do
  def main(input) do
    {map, bytes} = parse(input)

    IO.puts("Part one result: #{part_one(map)}")
    IO.puts("Part two result: #{part_two(map, bytes)}")
  end

  defp parse(input) do
    {bytes, remaining_bytes} =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, ",", trim: true))
      |> Enum.map(fn [x, y] -> {String.to_integer(x), String.to_integer(y)} end)
      |> Enum.split(1024)

    map =
      for x <- 0..70, y <- 0..70, {x, y} not in bytes do
        {x, y}
      end
      |> MapSet.new()

    {map, remaining_bytes}
  end

  # A* algorithm
  defp part_one(map) do
    start = {0, 0}
    goal = {70, 70}
    queue = :gb_sets.singleton({heuristic(start, goal), start, []})
    map = MapSet.delete(map, start)
    search(map, queue, goal)
  end

  defp part_two(map, [byte | bytes]) do
    start = {0, 0}
    goal = {70, 70}
    queue = :gb_sets.singleton({heuristic(start, goal), start, []})
    map = MapSet.delete(map, start) |> MapSet.delete(byte)

    case search(map, queue, goal) do
      nil -> "#{elem(byte, 0)},#{elem(byte, 1)}"
      _ -> part_two(map, bytes)
    end
  end

  defp search(map, queue, goal) do
    case take_next(queue) do
      nil ->
        nil

      {{_score, ^goal, prevs}, _queue} ->
        length(prevs)

      {{_score, position, prevs}, queue} ->
        {queue, map} =
          neighbours(position, map)
          |> Enum.reduce({queue, map}, fn neighbour, {queue, map} ->
            score = length(prevs) + heuristic(neighbour, goal)
            map = MapSet.delete(map, neighbour)
            queue = :gb_sets.add_element({score, neighbour, [position | prevs]}, queue)
            {queue, map}
          end)

        search(map, queue, goal)
    end
  end

  defp neighbours({x, y}, map) do
    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> Enum.filter(&MapSet.member?(map, &1))
  end

  defp take_next(queue) do
    if :gb_sets.is_empty(queue) do
      nil
    else
      :gb_sets.take_smallest(queue)
    end
  end

  defp heuristic({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  # fun
  def print_map(path) do
    lines =
      for x <- 0..70, reduce: "" do
        lines ->
          line =
            for y <- 0..70, reduce: "" do
              line ->
                line <>
                  cond do
                    {y, x} in path -> "O"
                    # {y, x} in bytes -> "#"
                    true -> "."
                  end
            end

          lines <> line <> "\n"
      end

    Process.sleep(50)
    IO.puts(IO.ANSI.clear())
    IO.puts(lines)
  end
end

System.argv()
|> hd()
|> File.read!()
|> Day18.main()
