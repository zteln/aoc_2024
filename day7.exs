defmodule Day7 do
  def main(input) do
    equations = parse(input)

    IO.inspect("Part one result: #{part_one(equations)}")
    IO.inspect("Part two result: #{part_two(equations)}")
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.split(&1, ":", trim: true))
    |> Enum.map(fn [test_value, numbers] ->
      [
        String.to_integer(test_value),
        String.split(numbers, " ", trim: true) |> Enum.map(&String.to_integer/1)
      ]
    end)
  end

  defp part_one(equations) do
    equations
    |> Enum.filter(fn [test_value, numbers] ->
      operators([&Kernel.+/2, &Kernel.*/2], length(numbers) - 1)
      |> Enum.map(fn ops ->
        perform_ops(numbers, ops)
      end)
      |> Enum.any?(&(&1 == test_value))
    end)
    |> Enum.reduce(0, fn [res, _], acc -> res + acc end)
  end

  defp part_two(equations) do
    equations
    |> Task.async_stream(
      fn [test_value, numbers] ->
        [
          test_value,
          operators([&Kernel.+/2, &Kernel.*/2, &concat/2], length(numbers) - 1)
          |> Enum.map(fn ops ->
            perform_ops(numbers, ops)
          end)
        ]
      end,
      timeout: :infinity
    )
    |> Stream.map(&elem(&1, 1))
    |> Stream.filter(fn [test_value, numbers] ->
      Enum.any?(numbers, &(&1 == test_value))
    end)
    |> Enum.reduce(0, fn [res, _], acc -> res + acc end)
  end

  defp perform_ops([res], []), do: res

  defp perform_ops([arg1, arg2 | args], [op | ops]) do
    perform_ops([op.(arg1, arg2) | args], ops)
  end

  defp operators(operators, 1), do: Enum.map(operators, &[&1])

  defp operators(operators, len) do
    Enum.map(operators, fn x ->
      [
        x,
        Enum.map(operators(operators, len - 1), fn y ->
          y
        end)
      ]
    end)
    |> Enum.flat_map(&expand/1)
  end

  defp expand([op, inner]) do
    Enum.map(inner, &([op] ++ &1))
  end

  # courtesy https://github.com/bjorng/advent-of-code/blob/main/2024/day07/lib/day07.ex
  defp concat(a, b) do
    shift(a, b) + b
  end

  defp shift(a, 0), do: a

  defp shift(a, b) do
    shift(a * 10, div(b, 10))
  end
end

System.argv()
|> hd()
|> File.read!()
|> Day7.main()
