defmodule Password do

  def to_list(number), do: to_list(number, [])

  def to_list(number, digits) when number < 10, do: [number | digits]
  def to_list(number, digits), do: to_list(div(number, 10), [Integer.mod(number, 10) | digits])

  def has_six_digits(digits), do: length(digits) == 6
  
  def is_monotonous(digits)
  def is_monotonous([_]), do: true
  def is_monotonous([a, b | rest]), do: a <= b && is_monotonous([b | rest])

  def has_siamese(digits)
  def has_siamese([_]), do: false
  def has_siamese([a, b | rest]), do: a == b || has_siamese([b | rest])

  # we do a trick and inject a -1 at the beginning and at the end, so we can match easier
  def has_siamese_twin(digits), do: has_siamese_twin_([-1 | digits] ++ [-1])
  def has_siamese_twin_([a, b, c]), do: false
  def has_siamese_twin_([a, b, c, d | rest]), do: (a != b && b == c && c != d) || has_siamese_twin_([b, c, d | rest])

  def valid?(number) do
    digits = to_list(number)
    has_six_digits(digits) && is_monotonous(digits) && has_siamese(digits)
  end

  def strict_valid?(number) do
    digits = to_list(number)
    has_six_digits(digits) && is_monotonous(digits) && has_siamese_twin(digits)
  end
end

range = 254032..789860

range
  |> Enum.filter(&Password.valid?/1)
  |> length
  |> IO.inspect
# => 1033

range
  |> Enum.filter(&Password.strict_valid?/1)
  |> length
  |> IO.inspect
# => 670