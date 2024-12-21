defmodule Day20 do
  def main(input) do
    {track, walls, start, finish} = parse(input)

    IO.puts("Part one result: #{part_one(track, walls, start, finish)}")
    IO.puts("Part two result: #{part_two(track, start, finish)}")
  end

  defp part_one(track, walls, start, finish) do
    queue = :gb_sets.singleton({taxicab_distance(start, finish), start, [start]})

    [_ | path] =
      a_star(track, queue, finish, &[&1 | &2], &(&1 + length(&2)))

    time = MapSet.size(track)

    {_, times} =
      path
      |> Enum.reverse()
      |> Enum.reduce({MapSet.new(), []}, fn point, {cheats, times} ->
        wall_neighbours(point, walls, 1)
        |> Enum.reject(&MapSet.member?(cheats, &1))
        |> Enum.reduce({cheats, times}, fn wn, {cheats, times} ->
          track = MapSet.put(track, wn)
          queue = :gb_sets.singleton({taxicab_distance(start, finish), start, 0})
          {MapSet.put(cheats, wn), [time - a_star(track, queue, finish) | times]}
        end)
      end)

    times
    |> Enum.frequencies()
    |> Enum.filter(&(elem(&1, 0) >= 100))
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp part_two(track, start, finish) do
    queue = :gb_sets.singleton({taxicab_distance(start, finish), start, [start]})

    [_ | path] =
      a_star(track, queue, finish, &[&1 | &2], &(&1 + length(&2)))

    solve(path, 20)
  end

  # Cool and efficient solution via https://elixirforum.com/t/advent-of-code-2024-day-20/68256/6
  defp solve([], _cheats), do: 0

  defp solve([hd | tl], cheat_step) do
    cheats =
      tl
      |> Enum.drop(100)
      |> Enum.with_index()
      |> Enum.count(fn {point, idx} ->
        d = taxicab_distance(hd, point)
        d <= cheat_step and idx + 1 >= d
      end)

    cheats + solve(tl, cheat_step)
  end

  defp a_star(track, queue, finish, accer \\ fn _, acc -> acc + 1 end, scorer \\ &(&1 + &2)) do
    case take_next(queue) do
      nil ->
        nil

      {{_score, ^finish, acc}, _queue} ->
        accer.(finish, acc)

      {{_score, point, acc}, queue} ->
        {queue, track} =
          neighbours(point, track)
          |> Enum.reduce({queue, track}, fn neighbour, {queue, track} ->
            score = scorer.(taxicab_distance(neighbour, finish), acc)

            {:gb_sets.add_element({score, neighbour, accer.(neighbour, acc)}, queue),
             MapSet.delete(track, neighbour)}
          end)

        a_star(track, queue, finish, accer, scorer)
    end
  end

  defp take_next(queue) do
    if :gb_sets.is_empty(queue) do
      nil
    else
      :gb_sets.take_smallest(queue)
    end
  end

  defp wall_neighbours(point, walls, levels, neighbours \\ MapSet.new())

  defp wall_neighbours(_, _, 0, neighbours) do
    neighbours
  end

  defp wall_neighbours({x, y}, walls, levels, neighbours) do
    case Process.get({x, y, levels}) do
      nil ->
        neighbours =
          neighbouring_dirs()
          |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
          |> Enum.filter(&MapSet.member?(walls, &1))
          |> Enum.reduce(neighbours, fn point, acc ->
            wall_neighbours(point, walls, levels - 1, MapSet.put(acc, point))
          end)

        Process.put({x, y, levels}, neighbours)
        neighbours

      neighbours ->
        neighbours
    end
  end

  defp neighbours({x, y}, track) do
    neighbouring_dirs()
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> Enum.filter(&MapSet.member?(track, &1))
  end

  defp taxicab_distance({x1, y1}, {x2, y2}) do
    abs(x1 - x2) + abs(y1 - y2)
  end

  defp neighbouring_dirs, do: [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]

  defp parse(input) do
    map =
      input
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)
      |> Enum.with_index(fn x, x_idx ->
        Enum.with_index(x, fn y, y_idx ->
          {{x_idx, y_idx}, y}
        end)
      end)
      |> List.flatten()
      |> Enum.into(%{})
      |> Enum.group_by(&elem(&1, 1))

    start = Map.get(map, "S") |> Enum.map(&elem(&1, 0)) |> List.first()
    finish = Map.get(map, "E") |> Enum.map(&elem(&1, 0)) |> List.first()
    walls = Map.get(map, "#") |> Enum.map(&elem(&1, 0)) |> MapSet.new()

    track =
      Map.get(map, ".")
      |> Enum.map(&elem(&1, 0))
      |> MapSet.new()
      |> MapSet.put(start)
      |> MapSet.put(finish)

    {track, walls, start, finish}
  end

  def print_map(path, track) do
    lines =
      for x <- 0..14, reduce: "" do
        lines ->
          lines <>
            for y <- 0..14, reduce: "" do
              line ->
                line <>
                  cond do
                    {x, y} in path -> "x"
                    {x, y} in track -> "."
                    true -> "#"
                  end
            end <> "\n"
      end

    Process.sleep(70)
    IO.puts(IO.ANSI.clear())
    IO.inspect(length(path), label: "LEN")
    IO.puts(lines)
  end
end

System.argv()
|> hd()
|> File.read!()
|> Day20.main()
