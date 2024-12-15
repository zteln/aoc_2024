defmodule Day14 do
  def main(input) do
    robots = parse(input)

    IO.puts("Part one result: #{part_one(robots)}")
    IO.puts("Part two result: #{part_two(robots)}")
  end

  defp parse(input) do
    input
    |> String.split("\n", trim: true)
    |> Enum.map(fn robot ->
      [[px, py], [vx, vy]] =
        Regex.scan(~r/(?<x>-*[[:digit:]]+),(?<y>-*[[:digit:]]+)/, robot, capture: :all_but_first)

      {{String.to_integer(px), String.to_integer(py)},
       {String.to_integer(vx), String.to_integer(vy)}}
    end)
  end

  defp part_one(robots) do
    wide = 101
    tall = 103

    robots
    |> Enum.map(fn robot ->
      {p, _} = move(robot, wide, tall, 100)
      p
    end)
    |> Enum.reject(fn {px, py} -> px == div(wide, 2) or py == div(tall, 2) end)
    |> Enum.group_by(fn {px, py} ->
      cond do
        px < div(wide, 2) and py < div(tall, 2) -> :first
        px > div(wide, 2) and py < div(tall, 2) -> :second
        px < div(wide, 2) and py > div(tall, 2) -> :third
        px > div(wide, 2) and py > div(tall, 2) -> :fourth
      end
    end)
    |> Enum.map(fn {_, quadrant} -> Enum.count(quadrant) end)
    |> Enum.product()
  end

  defp part_two(robots) do
    wide = 101
    tall = 103

    robots
    |> get_tree(wide, tall)
  end

  defp get_tree(robots, wide, tall, iter \\ 0) do
    robots
    |> tap(fn robots ->
      case Enum.find(robots, fn {p, _} -> has_tree_top(p, robots) end) do
        nil -> nil
        _ -> print_robots(robots, iter)
      end
    end)
    |> Enum.map(&move(&1, wide, tall))
    |> get_tree(wide, tall, iter + 1)
  end

  defp move({{px, py}, {vx, vy}}, wide, tall, seconds \\ 1) do
    {{Integer.mod(px + vx * seconds, wide), Integer.mod(py + vy * seconds, tall)}, {vx, vy}}
  end

  defp has_tree_top({px, py}, robots) do
    robot_positions = robots |> Enum.map(&elem(&1, 0)) |> MapSet.new()
    dirs = [{-1, 1}, {1, 1}, {-2, 2}, {2, 2}]
    Enum.all?(dirs, fn {dx, dy} -> MapSet.member?(robot_positions, {px + dx, py + dy}) end)
  end

  defp print_robots(robots, seconds) do
    robot_positions = robots |> Enum.map(&elem(&1, 0)) |> MapSet.new()

    Process.sleep(70)
    IO.puts("#{IO.ANSI.clear()}")

    IO.puts("SECONDS: #{seconds}")

    lines =
      for x <- 0..100, reduce: "" do
        lines ->
          line =
            for y <- 0..102, reduce: "" do
              line ->
                if {x, y} in robot_positions do
                  line <> "#"
                else
                  line <> "."
                end
            end

          lines <> line <> "\n"
      end

    IO.puts(lines)
    IO.puts("\n\n")
    robots
  end
end

System.argv()
|> hd()
|> File.read!()
|> Day14.main()
