defmodule Day19 do
  def main(input) do
    {patterns, designs} = parse(input)

    Task.async(fn -> IO.puts("Part one result: #{part_one(patterns, designs)}") end)
    |> Task.await()

    Task.async(fn -> IO.puts("Part two result: #{part_two(patterns, designs)}") end)
    |> Task.await()
  end

  defp parse(input) do
    [patterns, designs] =
      input
      |> String.split("\n\n")

    {String.split(patterns, ", ") |> MapSet.new(), String.split(designs, "\n", trim: true)}
  end

  defp part_one(patterns, designs) do
    Enum.map(designs, &check_design(&1, patterns))
    |> Enum.filter(& &1)
    |> Enum.count()
  end

  defp part_two(patterns, designs) do
    Enum.map(designs, &get_all_combos(&1, patterns))
    |> Enum.sum()
  end

  defp get_all_combos(design, patterns) do
    case get_memo(design) do
      nil ->
        for idx <- 0..(String.length(design) - 1) do
          {String.slice(design, 0..idx), String.slice(design, (idx + 1)..String.length(design))}
        end
        |> Enum.map(fn
          {prefix, ""} ->
            if MapSet.member?(patterns, prefix), do: 1, else: 0

          {prefix, suffix} ->
            if MapSet.member?(patterns, prefix), do: get_all_combos(suffix, patterns), else: 0
        end)
        |> List.flatten()
        |> Enum.sum()
        |> put_memo(design)

      res ->
        res
    end
  end

  defp check_design(design, patterns) do
    case get_memo(design) do
      nil ->
        if MapSet.member?(patterns, design) do
          true
        else
          for idx <- 0..(String.length(design) - 2) do
            {String.slice(design, 0..idx), String.slice(design, (idx + 1)..String.length(design))}
          end
          |> Enum.filter(fn {prefix, _suffix} ->
            MapSet.member?(patterns, prefix)
          end)
          |> Enum.map(fn {_prefix, suffix} -> check_design(suffix, patterns) end)
          |> List.flatten()
          |> Enum.uniq()
          |> Enum.find(false, &(&1 == true))
        end
        |> put_memo(design)

      res ->
        res
    end
  end

  defp put_memo(res, design) do
    Process.put(design, res)
    res
  end

  defp get_memo(design) do
    Process.get(design)
  end
end

System.argv()
|> hd()
|> File.read!()
|> Day19.main()
