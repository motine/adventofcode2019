# calculation = fn mass -> div(mass, 3) - 2 end

defmodule Program do
  # memory (address)
  # instruction (opcode, param)
  # instruction pointer

  def execute(operation, param1, param2, target_address, memory, instruction_pointer)

  def execute(99, _, _, _, memory, _) do
    Enum.at(memory, 0)
  end

  def execute(1, param1, param2, target_address, memory, instruction_pointer) do
    memory = List.replace_at(memory, target_address, Enum.at(memory, param1) + Enum.at(memory, param2))
    step(memory, instruction_pointer + 4)
  end

  def execute(2, param1, param2, target_address, memory, instruction_pointer) do
    memory = List.replace_at(memory, target_address, Enum.at(memory, param1) * Enum.at(memory, param2))
    step(memory, instruction_pointer + 4)
  end

  def step(memory, instruction_pointer) do # taking from head of the list would not be handy here
    [operation, param1, param2, target_address] = memory
      |> Enum.drop(instruction_pointer)
      |> Enum.take(4)
    execute(operation, param1, param2, target_address, memory, instruction_pointer)
  end

  def start(memory, noun, verb) do
    memory
      |> List.replace_at(1, noun)
      |> List.replace_at(2, verb)
      |> Program.step(0)
  end
end

memory = File.read!("2.txt")
  |> String.split(",")
  |> Enum.map(&String.to_integer/1)

# first task
Program.start(memory, 12, 2)
  |> IO.inspect
# => 2692315


# second task
combinations = for verb <- 0..99, noun <- 0..99, do: {verb, noun}

Enum.reduce_while(combinations, nil, fn {noun, verb}, _ ->
    output = Program.start(memory, noun, verb)
    if output == 19690720 do
      {:halt, 100 * noun + verb}
    else
      {:cont, nil}
    end
  end)
  |> IO.inspect
# => 9507

memory