defmodule Parameter do
  # takes an integer and splits the digits into a list (as described in day 5).
  # it reverses the list, so the mode of the first parameter is first in the list.
  # also, if the digits in the number are not as many as given in count, the list is padded with 0.
  # lastly, this function converts 1 to :immediate and 0 to :position
  def modes(_, 0), do: []
  def modes(number, count) do
    number
      |> digits([])
      |> pad(count)
      |> Enum.reverse
      |> Enum.map(&digit_to_symbol/1)
  end

  def digit_to_symbol(1), do: :immediate
  def digit_to_symbol(0), do: :position

  def digits(number, digits) when number < 10, do: [number | digits]
  def digits(number, digits), do: digits(div(number, 10), [Integer.mod(number, 10) | digits])

  def pad(list, count) when length(list) == count, do: list
  def pad(list, count) when length(list) < count, do: pad([0 | list], count)

  # returns the a list of tuples of the form {parameter_value, mode}
  # e.g.: [{77, :position}, {33, :immediate}, {6, :position}]
  def with_modes(params, mode_number) do
    Enum.zip(params, modes(mode_number, length(params)))
  end
end


defmodule Program do
  # memory (address)
  # instruction (opcode, param)
  # instruction pointer

  def value_for(memory, param_with_mode)
  def value_for(memory, {address, :position}), do: Enum.at(memory, address)
  def value_for(_, {value, :immediate}), do: value

  # def parameter_count(operation)
  def parameter_count(1), do: 3
  def parameter_count(2), do: 3
  def parameter_count(3), do: 1
  def parameter_count(4), do: 1
  def parameter_count(5), do: 2
  def parameter_count(6), do: 2
  def parameter_count(7), do: 3
  def parameter_count(8), do: 3
  def parameter_count(99), do: 0

  def execute(operation, params_with_modes, memory, instruction_pointer, input)

  # op code 1: add
  def execute(1, [a, b, {target_address, :position}], memory, instruction_pointer, _) do
    {
      List.replace_at(memory, target_address, value_for(memory, a) + value_for(memory, b)),
      instruction_pointer + 4,
      true
    }
  end

  # op code 2: multiply
  def execute(2, [a, b, {target_address, :position}], memory, instruction_pointer, _) do
    {
      List.replace_at(memory, target_address, value_for(memory, a) * value_for(memory, b)),
      instruction_pointer + 4,
      true
    }
  end

  # op code 3: input
  def execute(3, [{target_address, :position}], memory, instruction_pointer, input) do
    {
      List.replace_at(memory, target_address, input),
      instruction_pointer + 2,
      true
    }
  end

  # op code 4: output
  def execute(4, [target], memory, instruction_pointer, _) do
    IO.inspect(value_for(memory, target))
    {
      memory,
      instruction_pointer + 2,
      true
    }
  end

  # op code 5: jump-if-true
  def execute(5, [condition, address], memory, instruction_pointer, _) do
    p = if value_for(memory, condition) == 0, do: instruction_pointer + 3, else: value_for(memory, address)
    { memory, p, true }
  end

  # op code 6: jump-if-true
  def execute(6, [condition, address], memory, instruction_pointer, _) do
    p = if value_for(memory, condition) == 0, do: value_for(memory, address), else: instruction_pointer + 3
    { memory, p, true }
  end

  # op code 7: less than
  def execute(7, [a, b, {address, :position}], memory, instruction_pointer, _) do
    value = if value_for(memory, a) < value_for(memory, b), do: 1, else: 0
    {
      List.replace_at(memory, address, value),
      instruction_pointer + 4,
      true
    }
  end

  # op code 8: equals
  def execute(8, [a, b, {address, :position}], memory, instruction_pointer, _) do
    value = if value_for(memory, a) == value_for(memory, b), do: 1, else: 0
    {
      List.replace_at(memory, address, value),
      instruction_pointer + 4,
      true
    }
  end

  # op code 99: halt
  def execute(99, [], memory, instruction_pointer, _) do
    {
      memory,
      instruction_pointer + 2,
      false
    }
  end

  def step(memory, instruction_pointer, input) do # taking from head of the list can't be done
    [operation | rest] = Enum.drop(memory, instruction_pointer)
    
    opcode = Integer.mod(operation, 100)
    params = Enum.take(rest, parameter_count(opcode))
    params_with_modes = Parameter.with_modes(params, div(operation, 100)) # parameter and mode_number
    
    { memory, instruction_pointer, continue } = execute(opcode, params_with_modes, memory, instruction_pointer, input)
    if continue, do: step(memory, instruction_pointer, input), else: memory
  end

  def start(memory, input) do
    Program.step(memory, 0, input)
  end
end

memory = File.read!("5.txt")
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)

# first task
Program.start(memory, 1)
# => 8332629

Program.start(memory, 5)
# => 8805067