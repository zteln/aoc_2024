defmodule Day5 do
  def main(input) do
    {keys, lists} = parse(input)

    IO.puts("Part one result: #{part_one(keys, lists)}")
    IO.puts("Part two result: #{part_two(keys, lists)}")
  end

  defp parse(input) do
    [keys, lists] =
      input
      |> String.trim_trailing()
      |> String.split("\n\n")

    {parse_keys(keys), parse_lists(lists)}
  end

  defp parse_keys(keys) do
    keys
    |> String.split("\n")
    |> Enum.map(&String.split(&1, "|"))
    |> Enum.map(
      &Enum.map(&1, fn x ->
        {int, ""} = Integer.parse(x)
        int
      end)
    )
    |> Enum.map(&List.to_tuple/1)
    |> Enum.group_by(&elem(&1, 0))
    |> Enum.map(fn {key, afters} -> {key, Enum.map(afters, &elem(&1, 1))} end)
    |> Enum.into(%{})
  end

  defp parse_lists(lists) do
    lists
    |> String.split("\n")
    |> Enum.map(&String.split(&1, ","))
    |> Enum.map(
      &Enum.map(&1, fn x ->
        {int, ""} = Integer.parse(x)
        int
      end)
    )
  end

  defp part_one(keys, lists) do
    lists
    |> Enum.filter(&is_correct_page_order(&1, keys))
    |> Enum.reduce(0, &add_middle_page/2)
  end

  defp part_two(keys, lists) do
    lists
    |> Enum.filter(&(!is_correct_page_order(&1, keys)))
    |> Enum.map(&reorder_pages(&1, keys))
    |> Enum.reduce(0, &add_middle_page/2)
  end

  defp is_correct_page_order([], _keys), do: true

  defp is_correct_page_order([page | pages], keys) do
    case Enum.all?(pages, &(&1 in Map.get(keys, page, []))) do
      true -> is_correct_page_order(pages, keys)
      false -> false
    end
  end

  defp add_middle_page(pages, acc) do
    acc + Enum.at(pages, pages |> length() |> div(2))
  end

  defp reorder_pages(pages, keys, reordered_pages \\ [])
  defp reorder_pages([], _keys, reordered_pages), do: reordered_pages

  defp reorder_pages([page | pages], keys, reordered_pages) do
    case Enum.find(pages, &(&1 not in Map.get(keys, page, []))) do
      nil ->
        reorder_pages(pages, keys, reordered_pages ++ [page])

      p ->
        idx = Enum.find_index(pages, &(&1 == p))
        pages = List.replace_at(pages, idx, page)
        reorder_pages([p | pages], keys, reordered_pages)
    end
  end
end

System.argv()
|> hd()
|> File.read!()
|> Day5.main()
