defmodule Day24 do
  def main(input) do
    {values, rules} = parse(input)

    {part_one_time, part_one} = :timer.tc(fn -> part_one(values, rules) end, :millisecond)
    IO.puts("Part one result: #{part_one} completed in #{part_one_time} milliseconds")

    {part_two_time, part_two} = :timer.tc(fn -> part_two(values, rules) end, :millisecond)
    IO.puts("Part two result: #{part_two} completed in #{part_two_time} milliseconds")
  end

  defp part_one(values, rules) do
    solve(values, rules)
    |> to_decimal("z")
  end

  defp part_two(values, rules) do
    goal =
      goal(values)
      |> Enum.filter(fn {key, _} -> String.starts_with?(key, "z") end)
      |> Enum.sort_by(&elem(&1, 0))

    reference = solve(values, rules)

    backtrack(goal, reference, values, rules, [])
  end

  defp backtrack([_], _, _, _, swapped) do
    swapped
    |> Enum.sort()
    |> Enum.join(",")
  end

  defp backtrack([{key, output} | goal], reference, values, rules, swapped) do
    {op, _, _, _} = rule = find_rule(key, rules)

    if output != Map.get(reference, key) or op != :xor do
      {swaps, rules} = fix_rule(rule, rules)

      reference = solve(values, rules)

      backtrack(goal, reference, values, rules, swaps ++ swapped)
    else
      backtrack(goal, reference, values, rules, swapped)
    end
  end

  defp fix_rule({:xor, input1, input2, "z" <> suffix}, rules) do
    Enum.reduce(
      [{input1, find_rule(input1, rules)}, {input2, find_rule(input2, rules)}],
      {[], rules},
      fn
        {error, {:and, _, _, _}}, {swapped, rules} ->
          {_, _, _, correct} = find_alternative_rule("x" <> suffix, "y" <> suffix, rules, 1)
          {[error, correct | swapped], swap(error, correct, rules)}

        _, acc ->
          acc
      end
    )
  end

  defp fix_rule({_, _, _, "z" <> suffix = error}, rules) do
    {_, _, _, correct} = find_alternative_rule("x" <> suffix, "y" <> suffix, rules, 2)
    {[error, correct], swap(error, correct, rules)}
  end

  defp find_alternative_rule(wire1, wire2, rules, 1) do
    find_output(wire1, wire2, :xor, rules)
  end

  defp find_alternative_rule(wire1, wire2, rules, 2) do
    {_, _, _, output} = find_output(wire1, wire2, :xor, rules)
    find_output(output, :xor, rules)
  end

  defp find_output(input1, op, rules) do
    Enum.find(rules, fn
      {^op, ^input1, _, _} -> true
      {^op, _, ^input1, _} -> true
      _ -> false
    end)
  end

  defp find_output(input1, input2, op, rules) do
    Enum.find(rules, fn
      {^op, ^input1, ^input2, _} -> true
      {^op, ^input2, ^input1, _} -> true
      _ -> false
    end)
  end

  defp solve(values, []), do: values

  defp solve(values, [{op, arg1, arg2, res} = rule | rules]) do
    input1 = Map.get(values, arg1)
    input2 = Map.get(values, arg2)

    if input1 && input2 do
      output = op(op, input1, input2)
      values = Map.put(values, res, output)
      solve(values, rules)
    else
      solve(values, rules ++ [rule])
    end
  end

  defp goal(values) do
    x_decimal = to_decimal(values, "x")
    y_decimal = to_decimal(values, "y")

    Integer.to_string(x_decimal + y_decimal, 2)
    |> String.graphemes()
    |> Enum.reverse()
    |> Enum.with_index(fn bit, idx ->
      idx =
        if idx < 10 do
          "z0" <> to_string(idx)
        else
          "z" <> to_string(idx)
        end

      {idx, String.to_integer(bit)}
    end)
    |> Enum.into(%{})
  end

  defp swap(wire1, wire2, rules) do
    Enum.reduce(rules, [], fn
      {op, input1, input2, ^wire1}, acc -> [{op, input1, input2, wire2} | acc]
      {op, input1, input2, ^wire2}, acc -> [{op, input1, input2, wire1} | acc]
      rule, acc -> [rule | acc]
    end)
  end

  defp find_rule(output, rules) do
    Enum.find(rules, fn {_op, _input1, _input2, wire} -> wire == output end)
  end

  defp to_decimal(values, filter_key) do
    values
    |> Enum.filter(fn {key, _val} -> String.starts_with?(key, filter_key) end)
    |> Enum.sort_by(&elem(&1, 0))
    |> Enum.reduce("", fn {_, val}, acc ->
      to_string(val) <> acc
    end)
    |> Integer.parse(2)
    |> elem(0)
  end

  defp parse(input) do
    [values, rules] = String.split(input, "\n\n", trim: true)

    values =
      values
      |> String.split("\n")
      |> Enum.map(&String.split(&1, ":\s", trim: true))
      |> Enum.map(fn [key, val] -> {key, String.to_integer(val)} end)
      |> Enum.into(%{})

    rules =
      rules
      |> String.split("\n", trim: true)
      |> Enum.map(&String.split(&1, "\s->\s"))
      |> Enum.map(fn [op_and_args, output] ->
        [arg1, op, arg2] = String.split(op_and_args, "\s")

        op =
          case op do
            "AND" -> :and
            "OR" -> :or
            "XOR" -> :xor
          end

        {op, arg1, arg2, output}
      end)

    {values, rules}
  end

  defp op(:and, 1, 1), do: 1
  defp op(:and, _, _), do: 0
  defp op(:or, 0, 0), do: 0
  defp op(:or, arg1, arg2) when arg1 == 1 or arg2 == 1, do: 1
  defp op(:xor, arg1, arg2) when arg1 != arg2, do: 1
  defp op(:xor, _, _), do: 0
end

System.argv()
|> hd()
|> File.read!()
|> Day24.main()
