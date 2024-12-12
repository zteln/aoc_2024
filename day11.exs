defmodule Day11 do
  require Integer

  def main(input) do
    stones = parse(input)

    IO.puts("Part one result: #{part_one(stones)}")
    IO.puts("Part two result: #{part_two(stones)}")
  end

  defp parse(input) do
    input
    |> String.trim_trailing("\n")
    |> String.split(" ")
    |> Enum.map(&String.to_integer/1)
    |> Enum.frequencies()
  end

  defp part_one(stones) do
    solve(stones, 25)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp part_two(stones) do
    solve(stones, 75)
    |> Enum.map(&elem(&1, 1))
    |> Enum.sum()
  end

  defp solve(stones, 0), do: stones

  defp solve(stones, blinks) do
    stones
    |> Enum.reduce(%{}, fn {stone, freq}, stones ->
      handle_stone(stone)
      |> Enum.reduce(stones, fn new_stone, stones ->
        Map.update(stones, new_stone, freq, &(&1 + freq))
      end)
    end)
    |> solve(blinks - 1)
  end

  defp handle_stone(0), do: [1]

  defp handle_stone(stone) do
    stone_digits = Integer.digits(stone)
    stone_digits_length = length(stone_digits)

    if rem(stone_digits_length, 2) == 0 do
      {stone_digits1, stone_digits2} = Enum.split(stone_digits, div(stone_digits_length, 2))
      [Integer.undigits(stone_digits1), Integer.undigits(stone_digits2)]
    else
      [stone * 2024]
    end
  end
end

System.argv()
|> hd()
|> File.read!()
|> Day11.main()
