defmodule Day21 do
  def main(input) do
    codes = parse(input)
    IO.puts("Part one result: #{part_one(codes)}")
    # part_two(codes) |> IO.inspect()
  end

  defp part_one(codes) do
    Enum.map(codes, fn code ->
      number =
        Enum.reduce(code, 0, fn
          :a, acc -> acc
          int, acc -> acc * 10 + int
        end)

      codes =
        press(code, {:a, number_pad()})
        |> flatten()
        |> take_smallest()

      best =
        for _ <- 1..2, reduce: codes do
          codes ->
            codes
            |> Enum.flat_map(fn code ->
              press(code, {:a, dir_pad()})
              |> flatten()
              |> take_smallest()
            end)

            # |> Enum.uniq()
        end
        |> Enum.map(&length/1)
        |> Enum.min()

      number * best
    end)
    |> Enum.sum()
  end

  # defp part_two(codes) do
  # end

  defp press(codes, key, prevs \\ [])
  defp press([], _, prevs), do: prevs

  defp press([code | codes], {cursor, grid}, prevs) do
    start = find_key(cursor, grid)
    finish = find_key(code, grid)
    queue = :gb_sets.singleton({distance(start, finish), start, prevs})
    pad = Map.keys(grid) |> MapSet.new() |> MapSet.delete(start)

    a_stars(pad, queue, finish, find_key(:a, grid))
    |> MapSet.to_list()
    |> take_smallest()
    |> Enum.map(&(&1 ++ [:a]))
    |> Enum.map(&press(codes, {code, grid}, &1))
  end

  defp a_stars(pad, queue, finish, act, paths \\ MapSet.new()) do
    case take_next(queue) do
      nil ->
        paths

      {{_score, ^finish, path}, _queue} ->
        MapSet.put(paths, path)

      {{_score, cursor, path}, queue} ->
        {new_queue, new_pad} =
          adjacent(pad, cursor)
          |> Enum.reduce({queue, pad}, fn adj, {queue, pad} ->
            score = distance(adj, finish) + length(path) + distance(act, adj)

            queue =
              :gb_sets.add_element({score, adj, path ++ [translate(diff(adj, cursor))]}, queue)

            pad = MapSet.delete(pad, adj)

            {queue, pad}
          end)

        paths = a_stars(new_pad, new_queue, finish, act, paths)
        a_stars(pad, queue, finish, act, paths)
    end
  end

  defp take_next(queue) do
    if :gb_sets.is_empty(queue) do
      nil
    else
      :gb_sets.take_smallest(queue)
    end
  end

  defp adjacent(grid, {x, y}) do
    [{0, 1}, {0, -1}, {1, 0}, {-1, 0}]
    |> Enum.map(fn {dx, dy} -> {x + dx, y + dy} end)
    |> Enum.filter(&MapSet.member?(grid, &1))
  end

  defp distance({x1, y1}, {x2, y2}) when x1 == x2 or y1 == y2 do
    div(abs(x1 - x2) + abs(y1 - y2), 2)
  end

  defp distance({x1, y1}, {x2, y2}), do: abs(x1 - x2) + abs(y1 - y2)

  defp diff({x1, y1}, {x2, y2}), do: {x1 - x2, y1 - y2}

  defp find_key(key, grid) do
    {key, _} = Enum.find(grid, &(elem(&1, 1) == key))
    key
  end

  defp flatten(list, acc \\ [])
  defp flatten([], acc), do: acc

  defp flatten([a | b], acc) do
    if Enum.all?(a, &is_atom/1) do
      flatten(b, [a | acc])
    else
      acc = flatten(a, acc)
      flatten(b, acc)
    end
  end

  defp take_smallest(els) do
    els
    |> Enum.group_by(&length/1)
    |> Enum.min_by(&elem(&1, 0))
    |> elem(1)
  end

  defp translate({0, -1}), do: :<
  defp translate({-1, 0}), do: :^
  defp translate({0, 1}), do: :>
  defp translate({1, 0}), do: :v
  defp translate(key), do: key

  defp number_pad do
    %{
      {0, 0} => 7,
      {0, 1} => 8,
      {0, 2} => 9,
      {1, 0} => 4,
      {1, 1} => 5,
      {1, 2} => 6,
      {2, 0} => 1,
      {2, 1} => 2,
      {2, 2} => 3,
      {3, 1} => 0,
      {3, 2} => :a
    }
  end

  defp dir_pad do
    %{
      {0, 1} => :^,
      {0, 2} => :a,
      {1, 0} => :<,
      {1, 1} => :v,
      {1, 2} => :>
    }
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.graphemes/1)
    |> Enum.map(
      &Enum.map(&1, fn
        "A" -> :a
        num -> String.to_integer(num)
      end)
    )
  end
end

System.argv()
|> hd()
|> File.read!()
|> Day21.main()
