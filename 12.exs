# I think I went a little overboard with defining operators here...
defmodule CoordinateOperators do
  @doc """
  Add the individual components of the given lists.
      iex> ([1, 2] &&& [3, 4])
      [4, 6]
  """
  def a &&& b when is_list(a) and is_list(b), do: Enum.zip(a, b) |> Enum.map(fn {i, j} -> i+j end)
  
  @doc """
  Sum the absolute values of all components.
      iex> ~~~ [1, 2, -4]
      -1
  """
  def ~~~ a, do: a |> Enum.map(&abs/1) |> Enum.sum

  @doc """
  Returns a normalized, direction vector for each component of the given list.

      iex> ([1, 2, 3] <~> [3, 2, -1])
      [1, 0, -1]
  """
  def a <~> b when is_list(a) and is_list(b), do: Enum.zip(a, b) |> Enum.map(fn {i, j} -> i <~> j end)

  @doc "returns a normalized, direction (see example above"
  def a <~> b when is_integer(a) and is_integer(b) and a > b, do: -1
  def a <~> b when is_integer(a) and is_integer(b) and a < b, do: 1
  def a <~> b when is_integer(a) and is_integer(b), do: 0
end

defmodule Math do
  # adapted from: https://rosettacode.org/wiki/Least_common_multiple#Elixir
  # explanation for approach: https://en.wikipedia.org/wiki/Least_common_multiple#Using_the_greatest_common_divisor
  def gcd(a,0), do: abs(a)
  def gcd(a,b), do: gcd(b, rem(a,b))
  def lcm(a,b), do: div(abs(a*b), gcd(a,b))
  def lcm(a,b,c), do: lcm(a,b) |> lcm(c)  
end

defmodule Moon do
  defstruct [:position, velocity: [0, 0, 0]] # contains {x,y,z} integer tuples

  import CoordinateOperators
  import Math

  def step(moons) when is_list(moons), do: Enum.map(moons, &(step(&1, moons)))

  def step(moon, moons) do
    gravity = calculate_gravity(moon, moons)
    moon
      |> update_velocity(gravity)
      |> apply_velocity
  end

  def calculate_gravity(moon, moons) do
    Enum.reduce(moons, [0,0,0], fn other, acc -> acc &&& (moon.position <~> other.position) end) # for each pair calculate the direction vector and sum them up
  end

  def update_velocity(moon, gravity), do: %{moon | velocity: moon.velocity &&& gravity}
  
  def apply_velocity(moon), do: %{moon | position: moon.position &&& moon.velocity}

  def energy(moons) when is_list(moons), do: moons |> Enum.map(&energy/1) |> Enum.sum
  def energy(%Moon{position: p, velocity: v}), do: (~~~ p) * (~~~ v)


  @doc "checks if the two given moons have the same position along the given axis."
  def same_along_axis?(a, b, axis), do: Enum.at(a.position, axis) == Enum.at(b.position, axis)

  def repetition_duration(initial_moons) do
    # we can always compare with the initial state.
    # idea: The axes (x,y,z) are independent. So we find the period for each axis separately. Then we find the lowest common multiple (idea from comments at https://www.youtube.com/watch?v=9UcnA2x5s-U).
    x_duration = repetition_duration(step(initial_moons), initial_moons, 0, 2) # enduring the code duplication here for better readability
    y_duration = repetition_duration(step(initial_moons), initial_moons, 1, 2)
    z_duration = repetition_duration(step(initial_moons), initial_moons, 2, 2)
    lcm(x_duration, y_duration, z_duration)
  end

  @doc "repeats until all the moons have the same values along the given axis. axis can be 0..2 where 0 is x, 1 is y and 2 is z axis"
  def repetition_duration(moons, initial_moons, axis, counter) do
    same = initial_moons
      |> Enum.zip(moons)
      |> Enum.all?(fn {inital, current} -> same_along_axis?(inital, current, axis) end)
    if same, do: counter, else: repetition_duration(step(moons), initial_moons, axis, counter + 1)
  end

  def read do
    [
      %Moon{position: [ -3,  15, -11]},
      %Moon{position: [  3,  13, -19]},
      %Moon{position: [-13,  18,  -2]},
      %Moon{position: [  6,   0,  -1]}
    ]
  end
end

moons = Moon.read

Enum.reduce(1..1000, moons, fn _, acc -> Moon.step(acc) end)
  |> Moon.energy
  |> IO.inspect
# => 12070

Moon.repetition_duration(moons)
  |> IO.inspect
# => 500903629351944
