defmodule Day13 do
  def main(input) do
    input = parse(input)

    IO.puts("Part one result: #{part_one(input)}")
    IO.puts("Part two result: #{part_two(input)}")
  end

  defp parse(input) do
    input
    |> String.split("\n\n")
    |> Enum.map(&String.split(&1, "\n", trim: true))
    |> Enum.map(fn machine ->
      machine
      |> Enum.map(fn
        "Button A: " <> rest ->
          ["X", x, "Y", y] = String.split(rest, [",", "+", " "], trim: true)
          {:a, {String.to_integer(x), String.to_integer(y)}}

        "Button B: " <> rest ->
          ["X", x, "Y", y] = String.split(rest, [",", "+", " "], trim: true)
          {:b, {String.to_integer(x), String.to_integer(y)}}

        "Prize: " <> rest ->
          ["X", x, "Y", y] = String.split(rest, [",", "=", " "], trim: true)
          {:p, {String.to_integer(x), String.to_integer(y)}}
      end)
    end)
  end

  defp part_one(input) do
    input
    |> solve(&Enum.reject(&1, fn {{v1, v2}, _} -> v1 > 100 or v2 > 100 end))
  end

  defp part_two(input) do
    input
    |> Enum.map(fn [a: a, b: b, p: {px, py}] ->
      [a: a, b: b, p: {10_000_000_000_000 + px, 10_000_000_000_000 + py}]
    end)
    |> solve()
  end

  defp solve(input, filter \\ & &1) do
    input
    |> Enum.map(fn [a: {ax, ay}, b: {bx, by}, p: {px, py}] ->
      x_checker = fn n, m -> n * ax + m * bx == px end
      y_checker = fn n, m -> n * ay + m * by == py end
      matrix = {{ax, bx}, {ay, by}}
      inv_mat = inv_mat(matrix)
      vec = {px, py}
      {scalar_mul(det_mat(matrix), mat_mul_vec(inv_mat, vec)), {x_checker, y_checker}}
    end)
    |> filter.()
    |> Enum.map(fn {{v1, v2}, p} -> {{round(v1), round(v2)}, p} end)
    |> Enum.filter(fn {{v1, v2}, {x_checker, y_checker}} ->
      x_checker.(v1, v2) and y_checker.(v1, v2)
    end)
    |> Enum.map(fn {v, _} -> v end)
    |> Enum.map(&(elem(&1, 0) * 3 + elem(&1, 1)))
    |> Enum.sum()
  end

  defp inv_mat({{a, b}, {c, d}}) do
    {{d, -b}, {-c, a}}
  end

  defp det_mat({{a, b}, {c, d}}) do
    1 / (a * d - b * c)
  end

  defp mat_mul_vec({{a, b}, {c, d}}, {v1, v2}) do
    {a * v1 + b * v2, c * v1 + d * v2}
  end

  defp scalar_mul(c, {v1, v2}) do
    {c * v1, c * v2}
  end

  # defp part_one(input) do
  #   input
  #   |> Enum.map(fn [a: a, b: b, p: p] ->
  #     n = 0
  #     m = div(p, b)
  #     {{n, m}, {a, b, p}}
  #   end)
  #   |> Enum.map(&solve_machine/1)
  #   |> Enum.reject(&is_nil/1)
  #   |> Enum.reject(&(elem(&1, 0) > 100 or elem(&1, 1) > 100))
  #   |> Enum.reject(&(elem(&1, 0) < 0 or elem(&1, 1) < 0))
  #   |> Enum.map(&(elem(&1, 0) * 3 + elem(&1, 1)))
  #   |> Enum.sum()
  # end
  #
  # defp solve_machine({{n, m}, {a, b, p}}, prods \\ MapSet.new()) do
  #   prod = n * a + m * b
  #
  #   cond do
  #     MapSet.member?(prods, prod) -> nil
  #     prod == p and n * a + m * b == p -> {n, m}
  #     prod == p -> nil
  #     prod < p and m < 0 -> solve_machine({{n, m + 1}, {a, b, p}}, MapSet.put(prods, prod))
  #     prod > p and m < 0 -> solve_machine({{n - 1, m}, {a, b, p}}, MapSet.put(prods, prod))
  #     prod < p -> solve_machine({{n + 1, m}, {a, b, p}}, MapSet.put(prods, prod))
  #     prod > p -> solve_machine({{n, m - 1}, {a, b, p}}, MapSet.put(prods, prod))
  #   end
  # end
end

System.argv()
|> hd()
|> File.read!()
|> Day13.main()
