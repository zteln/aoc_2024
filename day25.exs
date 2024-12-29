defmodule Day25 do
  def main(input) do
    {keys, locks} = parse(input)

    {part_one_time, part_one} = :timer.tc(fn -> part_one(keys, locks, 0) end, :millisecond)

    IO.puts("Part one result: #{part_one} completed in #{part_one_time} milliseconds")
  end

  defp part_one([], _, fits), do: fits

  defp part_one([key | keys], locks, fits) do
    fits =
      Enum.reduce(locks, fits, fn lock, acc ->
        if fit?(key, lock), do: acc + 1, else: acc
      end)

    part_one(keys, locks, fits)
  end

  defp fit?(key, lock) do
    Map.merge(key, lock, fn _k, v1, v2 -> v1 + v2 end)
    |> Enum.all?(fn {_, amount} -> amount == 1 end)
  end

  defp parse(input) do
    input
    |> String.split("\n\n")
    |> Enum.reduce({[], []}, fn
      "#####" <> _ = schematic, {keys, locks} ->
        lock = reduce_schematic(schematic)
        {keys, [lock | locks]}

      "....." <> _ = schematic, {keys, locks} ->
        key = reduce_schematic(schematic)
        {[key | keys], locks}
    end)
  end

  defp reduce_schematic(schematic) do
    schematic
    |> String.split("\n")
    |> Enum.map(&String.graphemes/1)
    |> Enum.with_index(fn x, x_idx ->
      Enum.with_index(x, fn y, y_idx -> {{x_idx, y_idx}, y} end)
    end)
    |> List.flatten()
    |> Enum.filter(&(elem(&1, 1) == "#"))
    |> Enum.map(fn {coordinates, _} -> {coordinates, 1} end)
    |> Enum.into(%{})
  end
end

System.argv()
|> hd()
|> File.read!()
|> Day25.main()
