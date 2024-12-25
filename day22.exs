defmodule Day22 do
  import Bitwise

  def main(input) do
    buyers = parse(input)

    {part_one_time, part_one} =
      :timer.tc(fn -> part_one(buyers, 2000) end, :millisecond)

    {part_two_time, part_two} =
      :timer.tc(fn -> part_two(buyers, 2000) end, :second)

    IO.puts("Part one result: #{part_one} completed in #{part_one_time} milliseconds")
    IO.puts("Part two result: #{part_two} completed in #{part_two_time} seconds")
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
    price_changes = price_changes(buyers, amount)
    sequences = sequences(price_changes, MapSet.new())

    sequences
    |> Stream.chunk_every(4000)
    |> Task.async_stream(
      fn seqs ->
        test_sequences(seqs, price_changes)
        |> Enum.max()
      end,
      timeout: :infinity
    )
    |> Stream.map(&elem(&1, 1))
    |> Enum.max()
  end

  defp test_sequences(sequences, price_changes, acc \\ [])
  defp test_sequences([], _price_changes, acc), do: acc

  defp test_sequences([sequence | sequences], price_changes, acc) do
    sum =
      Enum.map(price_changes, fn {prices, changes} ->
        get_price(prices, changes, sequence)
      end)
      |> Enum.sum()

    test_sequences(sequences, price_changes, [sum | acc])
  end

  defp get_price(_, [], _sequence), do: 0

  defp get_price([_hd | tl_prices] = prices, [_hd_change | tl_changes] = changes, sequence) do
    if List.starts_with?(changes, sequence) do
      [_, _, _, _, price | _] = prices
      price
    else
      get_price(tl_prices, tl_changes, sequence)
    end
  end

  defp sequences([], acc), do: acc

  defp sequences([{_prices, changes} | price_changes], acc) do
    acc =
      Enum.chunk_every(changes, 4, 1, :discard)
      |> Enum.reduce(acc, &MapSet.put(&2, &1))

    sequences(price_changes, acc)
  end

  defp price_changes(buyers, amount, acc \\ [])
  defp price_changes([], _, acc), do: acc

  defp price_changes([buyer | buyers], amount, acc) do
    {prices, _} =
      Enum.reduce(1..amount, {[get_price(buyer)], buyer}, fn _, {prices, buyer} ->
        secret_number =
          buyer
          |> first()
          |> second()
          |> third()

        {[get_price(secret_number) | prices], secret_number}
      end)

    prices = Enum.reverse(prices)

    changes =
      Enum.chunk_every(prices, 2, 1, :discard)
      |> Enum.map(fn [a, b] -> b - a end)

    price_changes(buyers, amount, [{prices, changes} | acc])
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
