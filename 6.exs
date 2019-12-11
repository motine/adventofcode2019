defmodule Orbit do
  def parent_count(object, links) do
    if Map.has_key?(links, object), do: 1 + parent_count(links[object], links), else: 0
  end

  # returns a map of objects and it's distance from the given object
  # e.g. the example in B would yield:
  # distances_from("L")
  # => { K: 1, J: 2, E: 3 }
  def distances_from(object, links, offset \\ 0) do
    if Map.has_key?(links, object) do
      Map.merge(
        %{object => offset},
        distances_from(links[object], links, offset + 1)
        )
    else
      %{}
    end
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

# # gather all links between objects (two per relationship, one for each direction)
# edges = child_to_parent
#   |> Enum.reduce(%{}, fn {child, parent}, acc -> acc[child] = [] end)

# The second puzzle is the same as the distance between the two objects
# Djikstra is a little too complicated for this, so we do the following approach:
# - generate a map that maps all objects with the distance from YOU
# - generate a map that maps all objects with the distance from SAN
# - iterate the SAN map and check if the current distance from YOU plus the distance from SAN is lower than the prior iteration

distances_from_you = Orbit.distances_from("YOU", child_to_parent)
Orbit.distances_from("SAN", child_to_parent)
  |> Enum.reduce(100000,
    fn {object, distance}, min_distance -> 
      if Map.has_key?(distances_from_you, object) do
        new_min = distance + distances_from_you[object] - 2
        if new_min < min_distance, do: new_min, else: min_distance
      else
        min_distance
      end
    end)
  |> IO.inspect
# => 346