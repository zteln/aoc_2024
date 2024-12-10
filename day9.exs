defmodule Day9 do
  def main(input) do
    disk_map = input |> String.trim_trailing() |> parse()

    IO.puts("Part one result: #{part_one(disk_map)}")
    IO.puts("Part two result: #{part_two(disk_map)}")
  end

  defp parse(input, id \\ 0, is_file_block \\ true, disk_map \\ :queue.new())
  defp parse(<<>>, _id, _is_file_block, disk_map), do: disk_map

  defp parse(<<"0", rest::binary>>, id, is_file_block, disk_map) do
    parse(rest, id, !is_file_block, disk_map)
  end

  defp parse(<<x::binary-1, rest::binary>>, id, is_file_block, disk_map) do
    x = String.to_integer(x)

    disk_map =
      for _ <- 1..x, reduce: disk_map do
        disk_map ->
          if is_file_block do
            :queue.in(id, disk_map)
          else
            :queue.in(:free, disk_map)
          end
      end

    if is_file_block do
      parse(rest, id + 1, false, disk_map)
    else
      parse(rest, id, true, disk_map)
    end
  end

  defp part_one(disk_map) do
    fragment_compress(disk_map, [])
    |> Enum.reverse()
    |> Enum.with_index()
    |> Enum.reduce(0, fn {block, idx}, acc -> acc + block * idx end)
  end

  defp part_two(disk_map) do
    compress(disk_map, :queue.to_list(disk_map))
    |> Enum.reduce({0, 0}, fn
      :free, {pos, acc} -> {pos + 1, acc}
      block, {pos, acc} -> {pos + 1, acc + block * pos}
    end)
    |> elem(1)
  end

  defp compress(disk_map, dense_map) do
    case get_last_block_file(disk_map) do
      :empty ->
        dense_map

      {[block | _] = block_file, disk_map} ->
        case free_space_index(dense_map, block_file) do
          [] ->
            compress(disk_map, dense_map)

          _ ->
            dense_map =
              Enum.map(dense_map, fn
                ^block -> :free
                block -> block
              end)

            dense_map =
              free_space_index(dense_map, block_file)
              |> Enum.reduce(dense_map, fn idx, dense_map ->
                List.replace_at(dense_map, idx, block)
              end)

            compress(disk_map, dense_map)
        end
    end
  end

  defp free_space_index(dense_map, [block | _] = block_file) do
    grouped_dense_map =
      dense_map
      |> Enum.with_index()
      |> Stream.chunk_by(&elem(&1, 0))

    indices =
      grouped_dense_map
      |> Enum.filter(&Enum.all?(&1, fn {block, _idx} -> block == :free end))
      |> Enum.find([], &(length(&1) >= length(block_file)))
      |> Enum.take(length(block_file))
      |> Enum.map(&elem(&1, 1))

    block_file_indices =
      grouped_dense_map
      |> Enum.find([], &Enum.all?(&1, fn {b, _idx} -> b == block end))
      |> Enum.map(&elem(&1, 1))

    if Enum.all?(indices, &Enum.all?(block_file_indices, fn bfi -> bfi > &1 end)) do
      indices
    else
      []
    end
  end

  defp get_last_block_file(disk_map, block_file \\ []) do
    case get_last_block(disk_map) do
      :empty ->
        :empty

      {block, new_disk_map} ->
        if Enum.all?(block_file, &(&1 == block)) do
          get_last_block_file(new_disk_map, [block | block_file])
        else
          {block_file, disk_map}
        end
    end
  end

  defp fragment_compress(disk_map, dense_map) do
    case :queue.out(disk_map) do
      {:empty, _} ->
        dense_map

      {{:value, :free}, disk_map} ->
        case get_last_block(disk_map) do
          :empty ->
            dense_map

          {block, disk_map} ->
            fragment_compress(disk_map, [block | dense_map])
        end

      {{:value, block}, disk_map} ->
        fragment_compress(disk_map, [block | dense_map])
    end
  end

  defp get_last_block({:empty, _}), do: :empty
  defp get_last_block({{:value, :free}, disk_map}), do: get_last_block(:queue.out_r(disk_map))
  defp get_last_block({{:value, block}, disk_map}), do: {block, disk_map}
  defp get_last_block(disk_map), do: get_last_block(:queue.out_r(disk_map))
end

System.argv()
|> hd()
|> File.read!()
|> Day9.main()
