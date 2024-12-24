defmodule Day21 do
  def main(input) do
    codes = parse(input)

    {part_one_time, part_one} = :timer.tc(fn -> part_one(codes) end, :microsecond)
    {part_two_time, part_two} = :timer.tc(fn -> part_two(codes) end, :microsecond)

    IO.puts("Part one result: #{part_one} completed in #{part_one_time} microseconds")
    IO.puts("Part two result: #{part_two} completed in #{part_two_time} microseconds")
  end

  defp part_one(codes) do
    solve(codes, 2)
  end

  defp part_two(codes) do
    solve(codes, 25)
  end

  defp solve(codes, amount) do
    robots = for _ <- 1..amount, do: {:a, dir_pad()}
    robots = [{:a, number_pad()} | robots]

    Enum.map(codes, fn code ->
      number =
        Enum.reduce(code, 0, fn
          :a, acc -> acc
          int, acc -> acc * 10 + int
        end)

      length =
        press_codes(code, robots)
        |> Enum.sum()

      number * length
    end)
    |> Enum.sum()
  end

  defp press_codes([], _), do: []

  defp press_codes([code_point | code], [robot]) do
    {sequences, robot} = press(code_point, robot)

    [
      Enum.map(sequences, &Enum.count/1)
      |> Enum.min()
      | press_codes(code, [robot])
    ]
  end

  defp press_codes([code_point | code], [{cursor, _} = robot | robots]) do
    {min, robot} =
      case Process.get({:min, code_point, cursor, length(robots)}) do
        nil ->
          {sequences, robot} = press(code_point, robot)

          min =
            Enum.map(sequences, fn sequence ->
              press_codes(sequence, robots)
            end)
            |> Enum.map(&Enum.sum/1)
            |> Enum.min()

          Process.put({:min, code_point, cursor, length(robots)}, {min, robot})
          {min, robot}

        {min, robot} ->
          {min, robot}
      end

    [
      min
      | press_codes(code, [robot | robots])
    ]
  end

  defp press(code_point, {cursor, grid}) do
    sequences =
      case Process.get({:shortest_seqs, code_point, cursor}) do
        nil ->
          start = find_key(cursor, grid)
          finish = find_key(code_point, grid)
          queue = :gb_sets.singleton({distance(start, finish), start, []})
          pad = Map.keys(grid) |> MapSet.new() |> MapSet.delete(start)
          sequences = a_stars(pad, queue, finish) |> take_smallest()
          Process.put({:shortest_seqs, code_point, cursor}, sequences)
          sequences

        sequences ->
          sequences
      end

    {sequences, {code_point, grid}}
  end

  defp a_stars(pad, queue, finish, sequences \\ MapSet.new()) do
    case take_next(queue) do
      nil ->
        sequences

      {{_score, ^finish, sequence}, _queue} ->
        sequence = sequence ++ [:a]
        MapSet.put(sequences, sequence)

      {{_score, cursor, sequence}, queue} ->
        {new_queue, new_pad} =
          adjacent(pad, cursor)
          |> Enum.reduce({queue, pad}, fn adj, {queue, pad} ->
            score = distance(adj, finish) + length(sequence)
            key = translate(diff(adj, cursor))

            queue =
              :gb_sets.add_element({score, adj, sequence ++ [key]}, queue)

            pad = MapSet.delete(pad, adj)

            {queue, pad}
          end)

        sequences = a_stars(new_pad, new_queue, finish, sequences)
        a_stars(pad, queue, finish, sequences)
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
