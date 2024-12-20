defmodule Day17 do
  import Bitwise

  def main(input) do
    opcodes = %{
      0 => &adv/4,
      1 => &bxl/4,
      2 => &bst/4,
      3 => &jnz/4,
      4 => &bxc/4,
      5 => &out/4,
      6 => &bdv/4,
      7 => &cdv/4
    }

    {registers, program} = parse(input)

    IO.puts("Part one result: #{part_one(registers, program, opcodes)}")
    IO.puts("Part two result: #{part_two(program, opcodes)}")
  end

  defp part_one(registers, program, opcodes) do
    run_program(registers, program, 0, [], opcodes)
    |> Enum.reverse()
    |> Enum.join(",")
  end

  defp part_two(program, opcodes) do
    # Problem specific...
    # ops = fn a -> band(bxor(bxor(bxor(band(a, 7), 3), 5), bsr(a, bxor(band(a, 7), 3))), 7) end

    # not problem specific
    ops = fn a ->
      registers = %{a: a, b: 0, c: 0}

      run_program(registers, program, 0, [], opcodes)
      |> List.last()
    end

    [out | output] = Enum.reverse(program)

    initials =
      0b000..0b111
      |> Enum.filter(fn ini ->
        ops.(ini) == out
      end)

    reverse(output, initials, ops)
    |> Enum.min()
  end

  defp reverse([], as, _ops), do: as

  defp reverse([out | output], as, ops) do
    as =
      Enum.flat_map(as, fn ini ->
        0b000..0b111
        |> Enum.map(fn n ->
          bsl(ini, 3) + n
        end)
      end)
      |> Enum.filter(&(ops.(&1) == out))

    reverse(output, as, ops)
  end

  defp run_program(registers, program, pointer, out, opcodes) do
    op = Map.get(opcodes, Enum.at(program, pointer), &halt/4)

    case op.(registers, Enum.at(program, pointer + 1), pointer, out) do
      {registers, pointer, out} ->
        run_program(registers, program, pointer, out, opcodes)

      {:halt, out} ->
        out
    end
  end

  defp adv(%{a: a} = registers, operand, pointer, out) do
    operand = combo_operand(operand, registers)
    {Map.put(registers, :a, bsr(a, operand)), pointer + 2, out}
  end

  defp bxl(%{b: b} = registers, operand, pointer, out) do
    {Map.put(registers, :b, bxor(b, operand)), pointer + 2, out}
  end

  defp bst(registers, operand, pointer, out) do
    operand = combo_operand(operand, registers)
    {Map.put(registers, :b, band(operand, 7)), pointer + 2, out}
  end

  defp jnz(%{a: 0} = registers, _operand, pointer, out),
    do: {registers, pointer + 2, out}

  defp jnz(registers, operand, _pointer, out), do: {registers, operand, out}

  defp bxc(%{b: b, c: c} = registers, _operand, pointer, out) do
    {Map.put(registers, :b, bxor(b, c)), pointer + 2, out}
  end

  defp out(registers, operand, pointer, out) do
    operand = combo_operand(operand, registers)
    {registers, pointer + 2, [band(operand, 7) | out]}
  end

  defp bdv(%{a: a} = registers, operand, pointer, out) do
    operand = combo_operand(operand, registers)
    {Map.put(registers, :b, bsr(a, operand)), pointer + 2, out}
  end

  defp cdv(%{a: a} = registers, operand, pointer, out) do
    operand = combo_operand(operand, registers)
    {Map.put(registers, :c, bsr(a, operand)), pointer + 2, out}
  end

  defp halt(_, _, _, out), do: {:halt, out}

  defp combo_operand(0, _), do: 0
  defp combo_operand(1, _), do: 1
  defp combo_operand(2, _), do: 2
  defp combo_operand(3, _), do: 3
  defp combo_operand(4, %{a: a}), do: a
  defp combo_operand(5, %{b: b}), do: b
  defp combo_operand(6, %{c: c}), do: c

  defp parse(input) do
    [registers, program] = String.split(input, "\n\n")

    registers =
      registers
      |> String.split("\n")
      |> Enum.reduce(%{}, fn
        "Register A: " <> a, acc -> Map.put(acc, :a, String.to_integer(a))
        "Register B: " <> b, acc -> Map.put(acc, :b, String.to_integer(b))
        "Register C: " <> c, acc -> Map.put(acc, :c, String.to_integer(c))
      end)

    "Program: " <> program = String.trim_trailing(program)

    program =
      program
      |> String.split(",")
      |> Enum.map(&String.to_integer/1)

    {registers, program}
  end
end

System.argv()
|> hd()
|> File.read!()
|> Day17.main()
