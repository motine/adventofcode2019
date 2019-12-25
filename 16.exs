defmodule FFT do
  @pattern [0, 1, 0, -1]

  @doc """
  Returns a Stream with the pattern for the given position.
  `position` is assumed to start at 0.

  ## Examples

      iex> FFT.pattern_stream(0) |> Enum.take(10) |> Enum.to_list
      [1, 0, -1, 0, 1, 0, -1, 0, 1, 0]
      iex> FFT.pattern_stream(2) |> Enum.take(10) |> Enum.to_list
      [0,0, 1,1,1, 0,0,0, -1,-1]
  """
  def pattern_stream(position) do
    pattern = for p <- @pattern, _ <- 0..position, do: p
    pattern
      |> Stream.cycle
      |> Stream.drop(1)
  end

  @doc """
  Actually perform the calculation.
  """
  def calc(input) do
    input
      |> Stream.with_index
      |> Stream.map(fn {_, index} -> calc_position(input, index) end)
      |> Enum.to_list
  end

  @doc """
  Calculate the result for the given position.

  ## Examples

      iex> FFT.calc_position([1,2,3,4,5,6,7,8], 0)
      4
      iex> FFT.calc_position([1,2,3,4,5,6,7,8], 1)
      8
  """
  def calc_position(input, position) do
    input
      |> Stream.zip(pattern_stream(position))
      |> Stream.map(fn {a, b} -> a * b end)
      |> Enum.sum
      |> abs
      |> Integer.mod(10)
  end
end

input = File.read!("16.txt")
  |> String.codepoints
  |> Enum.map(&String.to_integer/1)

IO.puts("This will take 90 sec...")
Enum.reduce(1..100, input, fn _, acc -> FFT.calc(acc) end)
  |> Enum.take(8)
  |> IO.inspect
# => 44098263