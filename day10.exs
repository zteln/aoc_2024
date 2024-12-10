defmodule Day10 do
  def main(input) do
    map = parse(input)
    trailheads = trailheads(map)

    IO.puts("Part one result: #{part_one(map, trailheads)}")
    IO.puts("Part two result: #{part_two(map, trailheads)}")
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(&Enum.map(&1, fn x -> String.to_integer(x) end))
    |> Enum.with_index(fn x, x_idx ->
      Enum.with_index(x, fn y, y_idx ->
        {{x_idx, y_idx}, y}
      end)
    end)
    |> List.flatten()
    |> Enum.into(%{})
  end

  defp trailheads(map) do
    map
    |> Enum.filter(fn {_pos, height} -> height == 0 end)
    |> Enum.into(%{})
  end

  defp part_one(map, trailheads) do
    solve(map, trailheads, &Enum.uniq(&1))
  end

  defp part_two(map, trailheads) do
    solve(map, trailheads)
  end

  defp solve(map, trailheads, transformer \\ & &1) do
    trailheads
    |> Task.async_stream(fn trailhead ->
      traverse(map, trailhead)
      |> List.flatten()
      |> transformer.()
      |> Enum.count()
    end)
    |> Stream.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp traverse(_map, {pos, 9}), do: pos

  defp traverse(map, {{x, y}, height}) do
    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
    |> Enum.map(fn {dx, dy} ->
      new_pos = {x + dx, y + dy}

      case Map.get(map, new_pos) do
        new_height when new_height == height + 1 ->
          traverse(map, {new_pos, new_height})

        _ ->
          []
      end
    end)
  end
end

System.argv()
|> hd()
|> File.read!()
|> Day10.main()
