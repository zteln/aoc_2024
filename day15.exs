defmodule Day15 do
  def main(input) do
    IO.puts("Part one result: #{part_one(input)}")
    IO.puts("Part two result: #{part_two(input)}")
  end

  defp parse(input, expander \\ & &1) do
    [map, instructions] = String.split(input, "\n\n", trim: true)

    map =
      map
      |> String.split("\n")
      |> Enum.map(&String.graphemes/1)
      |> expander.()
      |> Enum.with_index(fn x, x_idx ->
        Enum.with_index(x, fn y, y_idx -> {{x_idx, y_idx}, [y]} end)
      end)
      |> List.flatten()
      |> Enum.map(fn
        {key, ["."]} -> {key, []}
        val -> val
      end)
      |> Enum.into(%{})

    instructions =
      instructions
      |> String.split("\n")
      |> Enum.join()
      |> String.to_charlist()

    {map, instructions}
  end

  defp part_one(input) do
    {map, instructions} = parse(input)
    solve(map, instructions, "O")
  end

  defp part_two(input) do
    {map, instructions} =
      parse(input, fn map ->
        map
        |> Enum.map(fn line ->
          Enum.flat_map(line, fn
            "." -> [".", "."]
            "#" -> ["#", "#"]
            "O" -> ["[", "]"]
            "@" -> ["@", "."]
          end)
        end)
      end)

    solve(map, instructions, "[")
  end

  defp solve(map, [], obstacle) do
    map
    |> Enum.filter(&(elem(&1, 1) == [obstacle]))
    |> Enum.map(&elem(&1, 0))
    |> Enum.map(&(elem(&1, 0) * 100 + elem(&1, 1)))
    |> Enum.sum()
  end

  defp solve(map, [instruction | instructions], obstacle) do
    dir = dir(instruction)
    {cursor, _} = Enum.find(map, &(elem(&1, 1) == ["@"]))

    case move(map, cursor, dir) do
      :blocked -> solve(map, instructions, obstacle)
      map -> solve(map, instructions, obstacle)
    end
  end

  defp move(:blocked, _, _), do: :blocked

  defp move(map, {x, y}, {dx, dy}) do
    case Map.get(map, {x + dx, y + dy}) do
      ["#"] ->
        :blocked

      [] ->
        move_cursor(map, {x, y}, {dx, dy})

      ["O"] ->
        move_cursor(map, {x, y}, {dx, dy})
        |> move({x + dx, y + dy}, {dx, dy})

      ["["] when {dx, dy} == {1, 0} or {dx, dy} == {-1, 0} ->
        move_cursor(map, {x, y}, {dx, dy})
        |> move({x + dx, y + dy}, {dx, dy})
        |> move({x + dx, y + 1 + dy}, {dx, dy})

      ["]"] when {dx, dy} == {1, 0} or {dx, dy} == {-1, 0} ->
        move_cursor(map, {x, y}, {dx, dy})
        |> move({x + dx, y + dy}, {dx, dy})
        |> move({x + dx, y - 1 + dy}, {dx, dy})

      ["]"] ->
        move_cursor(map, {x, y}, {dx, dy})
        |> move({x + dx, y + dy}, {dx, dy})

      ["["] ->
        move_cursor(map, {x, y}, {dx, dy})
        |> move({x + dx, y + dy}, {dx, dy})
    end
  end

  defp move_cursor(map, {x, y}, {dx, dy}) do
    {obj, objs} = Map.get(map, {x, y}) |> Enum.split(1)

    map
    |> Map.update({x + dx, y + dy}, obj, &(&1 ++ obj))
    |> Map.put({x, y}, objs)
  end

  defp dir(?>), do: {0, 1}
  defp dir(?v), do: {1, 0}
  defp dir(?<), do: {0, -1}
  defp dir(?^), do: {-1, 0}
end

System.argv()
|> hd()
|> File.read!()
|> Day15.main()
