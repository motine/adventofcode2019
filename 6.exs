defmodule Orbit do
  def parent_count(object, links) do
    if Map.has_key?(links, object), do: 1 + parent_count(links[object], links), else: 0
  end
end

# gather a list which maps the orbiting object to its parent (yes, we do reverse here)
child_to_parent = File.read!("6.txt")
  |> String.split
  |> Enum.into(%{}, fn line -> 
    line
      |> String.split(")")
      |> Enum.reverse
      |> List.to_tuple
    end)

child_to_parent
  |> Map.keys
  |> MapSet.new # make them unique
  |> Enum.map(&Orbit.parent_count(&1, child_to_parent))
  |> Enum.sum
  |> IO.inspect
# => 154386