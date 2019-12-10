calculation = fn mass -> div(mass, 3) - 2 end

masses = File.read!("1.txt")
  |> String.split()
  |> Enum.map(&String.to_integer/1)

# the following solves the first
masses
  |> Enum.map(calculation)
  |> Enum.sum
  |> IO.inspect
# => 3262991

# the second...

corrected_calculation = fn mass ->
  mass
    |> calculation.()
    |> Stream.unfold(fn
        fuel when fuel <= 0 -> nil
        fuel -> {fuel, calculation.(fuel)}
      end)
    |> Enum.sum
  end

masses
  |> Enum.map(corrected_calculation)
  |> Enum.sum
  |> IO.inspect
# => 4891620
