defmodule Day8 do
  def main(input) do
    {antenna_map, max_range} = parse(input)

    IO.puts("Part one result: #{part_one(antenna_map, max_range)}")
    IO.puts("Part two result: #{part_two(antenna_map, max_range)}")
  end

  defp parse(input) do
    map =
      input
      |> String.split("\n", trim: true)
      |> Enum.map(&String.to_charlist/1)

    antenna_map =
      map
      |> Enum.with_index(fn line, line_idx ->
        Enum.with_index(line, fn part, part_idx ->
          {{line_idx, part_idx}, part}
        end)
      end)
      |> List.flatten()
      |> Enum.reduce(%{}, fn
        {_pos, ?.}, acc -> acc
        {pos, c}, acc -> Map.update(acc, c, [pos], &[pos | &1])
      end)

    max_x = map |> length()
    max_y = map |> hd() |> length()

    {antenna_map, {max_x, max_y}}
  end

  defp part_one(antenna_map, max_range) do
    solve(antenna_map, max_range, false)
  end

  defp part_two(antenna_map, max_range) do
    solve(antenna_map, max_range, true)
  end

  defp solve(antenna_map, max_range, max?) do
    Enum.reduce(antenna_map, [], fn {_c, antennas}, antinodes ->
      find_antinodes(antennas, antinodes, max_range, max?)
    end)
    |> List.flatten()
    |> Enum.uniq()
    |> Enum.count()
  end

  defp find_antinodes([], antinodes, _max_range, _limit), do: antinodes

  defp find_antinodes([antenna | antennas], antinodes, max_range, max?) do
    new_antinodes = Enum.flat_map(antennas, &calculate_antinodes(antenna, &1, max_range, max?))

    find_antinodes(antennas, [new_antinodes | antinodes], max_range, max?)
  end

  defp calculate_antinodes(antenna1, antenna2, max_range, max?) do
    diff = vector_op(antenna1, antenna2, &Kernel.-/2)

    limit_range(diff, max_range, max?)
    |> Enum.flat_map(fn limit ->
      diff = vector_op(diff, {limit, limit}, &Kernel.*/2)
      [vector_op(antenna1, diff, &Kernel.+/2), vector_op(antenna2, diff, &Kernel.-/2)]
    end)
    |> Enum.filter(&is_in_bounds(&1, max_range))
  end

  defp is_in_bounds({x, y}, {max_x, max_y}) do
    x in 0..(max_x - 1) && y in 0..(max_y - 1)
  end

  defp limit_range(_diff, _max_range, false), do: 1..1

  defp limit_range({x, y}, {max_x, max_y}, true) do
    0..max(abs(div(max_x, x)), abs(div(max_y, y)))
  end

  defp vector_op({x1, y1}, {x2, y2}, op) do
    {op.(x1, x2), op.(y1, y2)}
  end
end

System.argv()
|> hd()
|> File.read!()
|> Day8.main()
