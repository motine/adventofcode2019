defmodule Math do
  def div_round_up(dividend, divisor), do: if rem(dividend, divisor) > 0, do: div(dividend, divisor) + 1, else: div(dividend, divisor)
end

defmodule Element do
  @moduledoc """
  An element tuple is of the form: {count, name}. Example: {77, "GTGRP"}
  We represent the reaction list as a MapSet with the following form:
      %{
        output_name => { output_count, inputs },
        ...
      }
  Where inputs is a list of element tuples
  """

  import Math
  
  def parse(input) do
    input
      |> String.split("\n")
      |> Enum.map(&Element.parse_line/1)
      |> Enum.into(%{}, fn {{output_count, output_name}, inputs} -> {output_name, {output_count, inputs}} end)
  end

  @doc "returns a tuple of the form {output, inputs}, where output is an element tuple (see module docs) and inputs a list of element tuples."
  def parse_line(line) do
    [inputs_string, output_string] = String.split(line, " => ")
    inputs = inputs_string
      |> String.split(", ")
      |> Enum.map(&Element.parse_element/1)
    output = Element.parse_element(output_string)
    {output, inputs}
  end

  @doc "returns the number of elements and the element name as tuple"
  def parse_element(str) do
    [_, count, name] = Regex.run(~r/^(\d+)\s+(\w+)/, str)
    {String.to_integer(count), name}
  end

  @doc "returns the number of ORE needed to generate the given element name in the given count"
  def generate(reactions, wanted_count, wanted_name)
  def generate(_, count, "ORE"), do: count
  def generate(reactions, wanted_count, wanted_name) do

    {reaction_count, reaction_inputs} = reactions[wanted_name]
    
    times_to_run_the_reaction = div_round_up(wanted_count, reaction_count)
    
    reaction_inputs
      |> Enum.map(fn {rcount, rname} -> generate(reactions, times_to_run_the_reaction * rcount, rname) end)
      |> Enum.sum
  end
end

# Tests
#
# """
# 3 A => 1 FUEL
# 5 ORE => 2 A
# """ |> String.trim |> Element.parse |> Element.generate(1, "FUEL") |> IO.inspect

#   3 A => 1 FUEL
#   5 ORE => 2 A
# 10

#   11 ORE => 1 FUEL
# 11

#   3 A, 2 B => 1 FUEL
#   5 ORE => 2 A
#   2 ORE => 1 B
# 14

#   3 A, 2 B => 1 FUEL
#   5 ORE => 2 A
#   3 A => 1 B
# 25

#   3 A, 2 B => 1 FUEL
#   5 ORE => 2 A
#   3 A => 5 B
# 20

#   10 ORE => 10 A
#   1 ORE => 1 B
#   7 A, 1 B => 1 C
#   7 A, 1 C => 1 D
#   7 A, 1 D => 1 E
#   7 A, 1 E => 1 FUEL
# 31

#   157 ORE => 5 NZVS
#   165 ORE => 6 DCFZ
#   44 XJWVT, 5 KHKGT, 1 QDVJ, 29 NZVS, 9 GPVTF, 48 HKGWZ => 1 FUEL
#   12 HKGWZ, 1 GPVTF, 8 PSHF => 9 QDVJ
#   179 ORE => 7 PSHF
#   177 ORE => 5 HKGWZ
#   7 DCFZ, 7 PSHF => 2 XJWVT
#   165 ORE => 2 GPVTF
#   3 DCFZ, 7 NZVS, 5 HKGWZ, 10 PSHF => 8 KHKGT
# 13312 
"""
10 ORE => 10 A
1 ORE => 1 B
7 A, 1 B => 1 C
7 A, 1 C => 1 D
7 A, 1 D => 1 E
7 A, 1 E => 1 FUEL
""" |> String.trim |> Element.parse |> Element.generate(1, "FUEL") |> IO.inspect
# """ |> String.trim |> Element.parse |> Element.generate(1, "FUEL") |> IO.inspect

File.read!("14.txt")
  |> Element.parse
  |> Element.generate(1, "FUEL")
  |> IO.inspect
# => not 37617913
