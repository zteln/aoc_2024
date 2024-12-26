defmodule Day22 do
  import Bitwise

  def main(input) do
    buyers = parse(input)

    {part_one_time, part_one} =
      :timer.tc(fn -> part_one(buyers, 2000) end, :millisecond)

    {part_two_time, part_two} =
      :timer.tc(fn -> part_two(buyers, 2000) end, :millisecond)

    IO.puts("Part one result: #{part_one} completed in #{part_one_time} milliseconds")
    IO.puts("Part two result: #{part_two} completed in #{part_two_time} milliseconds")
  end

  defp part_one(buyers, amount, sum \\ 0)
  defp part_one([], _amount, sum), do: sum

  defp part_one([buyer | buyers], amount, sum) do
    buyer =
      Enum.reduce(1..amount, buyer, fn _, buyer ->
        buyer
        |> first()
        |> second()
        |> third()
      end)

    part_one(buyers, amount, sum + buyer)
  end

  defp part_two(buyers, amount) do
    price_changes(buyers, amount)
    |> Enum.max_by(&elem(&1, 1))
    |> elem(1)
  end

  defp price_changes(buyers, amount, acc \\ %{})
  defp price_changes([], _, acc), do: acc

  defp price_changes([buyer | buyers], amount, acc) do
    {acc, _, _, _, _} =
      Enum.reduce(1..amount, {acc, buyer, get_price(buyer), [], MapSet.new()}, fn
        _, {acc, prev_secret, prev_price, changes, seqs} ->
          secret =
            prev_secret
            |> first()
            |> second()
            |> third()

          price = get_price(secret)
          changes = [price - prev_price | changes]
          sequence = Enum.take(changes, 4)

          {acc, seqs} =
            if length(sequence) == 4 and not MapSet.member?(seqs, sequence) do
              {Map.update(acc, sequence, price, &(&1 + price)), MapSet.put(seqs, sequence)}
            else
              {acc, seqs}
            end

          {acc, secret, price, changes, seqs}
      end)

    price_changes(buyers, amount, acc)
  end

  defp get_price(secret), do: secret |> Integer.digits() |> List.last()

  defp first(buyer) do
    mix(buyer * 64, buyer)
    |> prune()
  end

  defp second(buyer) do
    mix(floor(buyer / 32), buyer)
    |> prune()
  end

  defp third(buyer) do
    mix(buyer * 2048, buyer)
    |> prune()
  end

  defp mix(number, secret) do
    bxor(number, secret)
  end

  defp prune(secret) do
    Integer.mod(secret, 16_777_216)
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(&String.to_integer/1)
  end
end

System.argv()
|> hd()
|> File.read!()
|> Day22.main()
