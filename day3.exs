defmodule DayThree do
  def main([file]) do
    input_stream =
      file
      |> File.stream!()

    part_one_result =
      input_stream
      |> Stream.flat_map(&part_one/1)
      |> Enum.sum()

    part_two_result =
      input_stream
      |> Enum.join()
      |> part_two()
      |> Enum.sum()

    IO.puts("Part one result: #{part_one_result}")
    IO.puts("Part two result: #{part_two_result}")
  end

  defp part_one(line) do
    Regex.scan(~r/mul\([[:digit:]]{1,3},[[:digit:]]{1,3}\)/, line)
    |> Enum.map(fn ["mul" <> rest] ->
      String.split(rest, ["(", ",", ")"], trim: true)
      |> Enum.map(fn sint ->
        {int, ""} = Integer.parse(sint)
        int
      end)
      |> Enum.product()
    end)
  end

  defp part_two(line) do
    Regex.scan(~r/mul\([[:digit:]]{1,3},[[:digit:]]{1,3}\)|do\(\)|don't\(\)/, line)
    |> Enum.reduce({true, []}, fn
      ["mul" <> _rest], {false, acc} ->
        {false, acc}

      ["mul" <> rest], {true, acc} ->
        prod =
          String.split(rest, ["(", ",", ")"], trim: true)
          |> Enum.map(fn sint ->
            {int, ""} = Integer.parse(sint)
            int
          end)
          |> Enum.product()

        {true, [prod | acc]}

      ["do()"], {false, acc} ->
        {true, acc}

      ["don't()"], {true, acc} ->
        {false, acc}

      _, acc ->
        acc
    end)
    |> elem(1)
  end
end

System.argv()
|> DayThree.main()
