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


defmodule Moon do
  defstruct [:position, velocity: [0, 0, 0]] # contains {x,y,z} integer tuples

  import CoordinateOperators

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

  def read do
    [
      %Moon{position: [ -3,  15, -11]},
      %Moon{position: [  3,  13, -19]},
      %Moon{position: [-13,  18,  -2]},
      %Moon{position: [  6,   0,  -1]}
    ]
  end
end


Enum.reduce(1..1000, Moon.read, fn _, acc -> Moon.step(acc) end)
  |> Moon.energy
  |> IO.inspect
# => 12070
