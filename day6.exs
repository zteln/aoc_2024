defmodule Day6 do
  def main(input) do
    map = parse(input)

    IO.puts("Part one result: #{part_one(map)}")
    IO.puts("Part two result: #{part_two(map)}")
  end

  defp parse(input) do
    input
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Enum.with_index(fn line, line_idx ->
      Enum.with_index(line, fn position, position_idx ->
        {{line_idx, position_idx}, position}
      end)
    end)
    |> List.flatten()
    |> Enum.into(%{})
  end

  defp part_one(map) do
    starting_position = find_starting_position(map)

    guard_path(map, starting_position)
    |> Enum.uniq_by(&elem(&1, 0))
    |> Enum.count()
  end

  defp part_two(map) do
    starting_position = find_starting_position(map)

    :persistent_term.put(__MODULE__, {map, starting_position})

    guard_path(map, starting_position)
    |> Enum.uniq_by(&elem(&1, 0))
    |> Enum.reject(&(elem(&1, 0) == elem(starting_position, 0)))
    |> Task.async_stream(fn {pos, _} ->
      {map, starting_position} = :persistent_term.get(__MODULE__)
      map = Map.put(map, pos, "#")

      case guard_path(map, starting_position) do
        :loop -> true
        _ -> false
      end
    end)
    |> Enum.map(fn {:ok, res} -> res end)
    |> Enum.filter(&(&1 != false))
    |> Enum.count()
  end

  defp find_starting_position(map) do
    Enum.find(map, fn {_pos, val} -> val in ["^", ">", "<", "v"] end)
  end

  defp guard_path(map, position, path \\ MapSet.new()) do
    if MapSet.member?(path, position) do
      :loop
    else
      case move(map, position) do
        nil -> MapSet.put(path, position)
        next_position -> guard_path(map, next_position, MapSet.put(path, position))
      end
    end
  end

  defp move(map, {{r, c}, "^"}) do
    case Map.get(map, {r - 1, c}) do
      "#" -> {{r, c}, ">"}
      nil -> nil
      _ -> {{r - 1, c}, "^"}
    end
  end

  defp move(map, {{r, c}, ">"}) do
    case Map.get(map, {r, c + 1}) do
      "#" -> {{r, c}, "v"}
      nil -> nil
      _ -> {{r, c + 1}, ">"}
    end
  end

  defp move(map, {{r, c}, "v"}) do
    case Map.get(map, {r + 1, c}) do
      "#" -> {{r, c}, "<"}
      nil -> nil
      _ -> {{r + 1, c}, "v"}
    end
  end

  defp move(map, {{r, c}, "<"}) do
    case Map.get(map, {r, c - 1}) do
      "#" -> {{r, c}, "^"}
      nil -> nil
      _ -> {{r, c - 1}, "<"}
    end
  end
end

System.argv()
|> hd()
|> File.read!()
|> Day6.main()
