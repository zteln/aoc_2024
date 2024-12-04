defmodule Day4 do
  def main([file]) do
    grid =
      file
      |> File.stream!()
      |> Stream.map(&String.trim_trailing/1)
      |> Stream.map(&String.graphemes/1)
      |> Enum.to_list()
      |> transform()

    part_one_result = part_one(grid)

    part_one_brute_result = part_one_brute(grid)

    part_two_result = part_two(grid)

    IO.puts("Part one result: #{part_one_result}")
    IO.puts("Part one brute result: #{part_one_brute_result}")
    IO.puts("Part two result: #{part_two_result}")
  end

  defp transform(grid) do
    Enum.with_index(grid, fn row, row_idx ->
      Enum.with_index(row, fn val, col_idx -> {{col_idx, row_idx}, val} end)
    end)
    |> List.flatten()
    |> Enum.into(%{})
  end

  ####################
  # Part 1: rotating #
  ####################

  defp part_one(grid) do
    {count, _} =
      Enum.reduce(0..3, {0, grid}, fn _, {acc, grid} ->
        {acc + count_in_grid(untransform(grid)) + count_in_grid(rotate_45_degrees(grid)),
         rotate_90_degrees(grid)}
      end)

    count
  end

  defp untransform(grid) do
    grid
    |> Enum.group_by(fn {{col, _}, _} -> col end)
    |> Enum.map(fn {_, row} ->
      row
      |> Enum.sort_by(fn {{_, row}, _} -> row end)
      |> Enum.map(fn {_, val} -> val end)
    end)
  end

  defp rotate_45_degrees(grid) do
    grid
    |> Map.keys()
    |> Enum.group_by(&(elem(&1, 0) + elem(&1, 1)))
    |> Enum.map(fn {idx, coords} -> {idx, Enum.sort_by(coords, &elem(&1, 0))} end)
    |> Enum.map(fn {_, coords} ->
      coords
      |> Enum.map(&Map.get(grid, &1))
    end)
  end

  defp rotate_90_degrees(grid) do
    {_, max_len} = grid |> Map.keys() |> Enum.max_by(&elem(&1, 1))

    grid
    |> Enum.map(fn {{x, y}, val} -> {{y, max_len - x}, val} end)
    |> Enum.into(%{})
  end

  defp count_in_grid(grid) do
    grid
    |> Enum.map(&Enum.join(&1))
    |> Enum.reduce(0, &count_in_line/2)
  end

  defp count_in_line(<<>>, count), do: count

  defp count_in_line(<<"XMAS", rest::binary>>, count) do
    count_in_line(rest, count + 1)
  end

  defp count_in_line(<<_char, rest::binary>>, count) do
    count_in_line(rest, count)
  end

  #######################
  # Part 1: brute-force #
  #######################

  defp part_one_brute(grid) do
    grid
    |> Enum.filter(fn
      {_, "X"} -> true
      _ -> false
    end)
    |> Enum.reduce(0, fn {{col, row}, _}, acc ->
      acc + Enum.count(check_dirs(grid, col, row))
    end)
  end

  defp check_dirs(grid, col, row) do
    dirs = for x <- -1..1, y <- -1..1, do: {x, y}

    Enum.map(dirs, fn dir ->
      Enum.map(0..3, fn mult ->
        col = col + elem(dir, 0) * mult
        row = row + elem(dir, 1) * mult
        grid[{col, row}]
      end)
      |> Enum.join()
    end)
    |> Enum.filter(&(&1 == "XMAS"))
  end

  ##########
  # Part 2 #
  ##########

  defp part_two(grid) do
    grid
    |> Enum.filter(fn
      {_, "A"} -> true
      _ -> false
    end)
    |> Enum.reduce(0, fn
      {{col, row}, _}, acc ->
        case {check_diagonally(grid, [{col - 1, row - 1}, {col + 1, row + 1}]),
              check_diagonally(grid, [{col + 1, row - 1}, {col - 1, row + 1}])} do
          {true, true} -> acc + 1
          _ -> acc
        end
    end)
  end

  defp check_diagonally(grid, dirs) do
    case Enum.map(dirs, fn dir -> grid[dir] end) do
      ["M", "S"] -> true
      ["S", "M"] -> true
      _ -> false
    end
  end
end

System.argv()
|> Day4.main()
