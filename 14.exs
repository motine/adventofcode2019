defmodule Math do
  def div_round_up(dividend, divisor), do: if rem(dividend, divisor) > 0, do: div(dividend, divisor) + 1, else: div(dividend, divisor)
end

defmodule MonotoneFunction do
  @doc """
  Find the given `target_output` by testing input values to function between `lower_input_bound` and `upper_input_bound`.
  Mind that the given function must be ascending monotonously.
  """
  def find_input_for_output(function, target_output, lower_input_bound, upper_input_bound)
  
  def find_input_for_output(_, target_output, lower_input_bound, upper_input_bound) when lower_input_bound == upper_input_bound, do: lower_input_bound

  def find_input_for_output(function, target_output, lower_input_bound, upper_input_bound) do
    # We test the value in the middle between the lower and upper bound
    # Depending on the result, we adjust the lower or upper bound respectively.
    test_input = div(lower_input_bound + upper_input_bound, 2)
    result = function.(test_input)
    if (result < target_output) do
      find_input_for_output(function, target_output, test_input+1, upper_input_bound)
    else
      find_input_for_output(function, target_output, lower_input_bound, test_input)
    end
  end
end

defmodule Element do
  @moduledoc """
  An element tuple is of the form: {count, name}. Example: {77, "GTGRP"}
  We represent the reaction list as a Map with the following form:
      %{
        output_name => { output_count, inputs },
        ...
      }
  Where `inputs` is a list of element tuples.
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

  @doc """
  `reactions` is the list of reactions as given by Element.parse/1.
  `needed` is the list of element tuples, which are still required (we try to boil down this list by applying a reaction until we end up with only ORE).
  `leftover` is the list of element tuples which can be used for subsequent reactions.
  """
  def react(reactions, needed, ore_count \\ 0, leftover \\ %{})

  def react(_, [], ore_count, _), do: ore_count # we have successfully reduced all needed elements to OREs. We are done!

  def react(reactions, [{count, "ORE"} | rest], ore_count, leftover), do: react(reactions, rest, ore_count+count, leftover) # we find an ORE tuple and move it over to the ore_count

  def react(reactions, [{needed_count, needed_name} | rest], ore_count, leftover) do # we need to reduce an element from the list by applying a reaction
    # find the reaction to perform in order to get the needed element
    {reaction_count, reaction_inputs} = reactions[needed_name]
    # calculate how many times we need the reaction while considering the leftover
    leftover_of_wanted = Map.get(leftover, needed_name, 0)
    needed_count_for_reaction = needed_count - leftover_of_wanted # how many elements do we need to produce
    times_to_run_the_reaction = div_round_up(needed_count_for_reaction, reaction_count)
    spare_of_needed_after_reaction = times_to_run_the_reaction * reaction_count - needed_count_for_reaction
    # assemble the list of needed elements for the reaction
    reaction_needs = Enum.reduce(reaction_inputs, [], fn {rcount, rname}, acc -> [{times_to_run_the_reaction * rcount, rname} | acc] end)

    react(reactions, reaction_needs ++ rest, ore_count, Map.put(leftover, needed_name, spare_of_needed_after_reaction))
  end
end

reactions = File.read!("14.txt")
  |> Element.parse

reactions
  |> Element.react([{1, "FUEL"}])
  |> IO.inspect
# => 346961

ores_available = 1000000000000
# let's just brute force it :)
# max_iter = 999999999999
# Enum.reduce_while(1..max_iter, nil, fn i, _ ->
#     ores = Element.react(reactions, [{i, "FUEL"}])
#     if ores < ores_available, do: {:cont, nil}, else: {:halt, i - 1}
#   end)
#   |> IO.inspect
# => 4065790 (after 3689 sec, almost an hour)

MonotoneFunction.find_input_for_output(fn input -> Element.react(reactions, [{input, "FUEL"}]) end, ores_available, 1, ores_available) - 1
  |> IO.inspect
# => 4065790 (after 2.7 sec)


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

# """
# 10 ORE => 10 A
# 1 ORE => 1 B
# 7 A, 1 B => 1 C
# 7 A, 1 C => 1 D
# 7 A, 1 D => 1 E
# 7 A, 1 E => 1 FUEL
# """ |> String.trim |> Element.parse |> Element.react([{1, "FUEL"}]) |> IO.inspect
