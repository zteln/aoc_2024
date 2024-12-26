defmodule Day23 do
  def main(input) do
    map = parse(input)

    {part_one_time, part_one} = :timer.tc(fn -> part_one(map) end, :millisecond)
    {part_two_time, part_two} = :timer.tc(fn -> part_two(map) end, :millisecond)

    IO.puts("Part one result: #{part_one} completed in #{part_one_time} milliseconds")
    IO.puts("Part two result: #{part_two} completed in #{part_two_time} milliseconds")
  end

  defp part_one(map) do
    keys =
      Enum.reduce(map, %{}, fn [l, r], acc ->
        acc
        |> Map.update(l, [r], &[r | &1])
        |> Map.update(r, [l], &[l | &1])
      end)

    keys
    |> Enum.map(fn {key, links} ->
      pairs =
        links
        |> pairs()
        |> Enum.map(&Enum.sort/1)
        |> Enum.uniq()

      {key, pairs}
    end)
    |> Enum.reduce(MapSet.new(), fn {key, pairs}, acc ->
      Enum.filter(pairs, fn [l, r] ->
        r in Map.get(keys, l) && l in Map.get(keys, r)
      end)
      |> Enum.map(fn links -> Enum.sort([key | links]) end)
      |> Enum.reduce(acc, &MapSet.put(&2, &1))
    end)
    |> Enum.filter(fn links ->
      Enum.any?(links, fn name -> String.starts_with?(name, "t") end)
    end)
    |> Enum.count()
  end

  # greedy algorithm, finding maximum clique in graph
  defp part_two(map) do
    vertices =
      Enum.reduce(map, MapSet.new(), fn [l, r], acc -> MapSet.put(acc, l) |> MapSet.put(r) end)

    keys =
      Enum.reduce(map, %{}, fn [l, r], acc ->
        acc
        |> Map.update(l, [r], &[r | &1])
        |> Map.update(r, [l], &[l | &1])
      end)

    Enum.reduce(vertices, MapSet.new(), fn vertex, cliques ->
      clique =
        Enum.reduce(vertices, [vertex], fn v, clique ->
          if Enum.all?(clique, &(v in Map.get(keys, &1))) do
            [v | clique]
          else
            clique
          end
        end)
        |> Enum.sort()

      MapSet.put(cliques, clique)
    end)
    |> Enum.max_by(&Enum.count/1)
    |> Enum.join(",")
  end

  defp pairs(links) do
    for l1 <- links, l2 <- links, l1 != l2, do: [l1, l2]
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, "-"))
  end
end

System.argv()
|> hd()
|> File.read!()
|> Day23.main()
