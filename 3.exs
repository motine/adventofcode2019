# load into struct [ {:r, 1009} ]

# distance of
# 654323456
# 543212345
# 4321x1234
# 543212345
# 654323456
#
# idea 1:
# repeat till we find a winner (with i counting up)
#   starting from the starting point, go through each point with distance i
#   is the point part of wire 1 and wire 2, then we have a winner
#
# idea 2:
# determine the min & max bounds
# generate a list of all points between min & max bounds
# for each point with accumulator (intersection list)
#   if the point is part of wire 1 and wire 2
#     calculate distance and add to accumulator
# return the minimum of the intersection list

# idea 3:
# go through each path segment of wire 1
#   for each point on the segment
#     if the point is part of wire 2
#       add point to accumulator
# return minimum of the accumulator
#
# idea 4: (winner)
# points1 = determine points on wire 1
# points2 = determine points on wire 2
# intersections = intersect(points1, points2)
# min(intersections)

defmodule Wire do
  # returns something like: [ {"R", "1009"}, {"U", "263"}, {"L", "517"}, ...]
  def parse(line) do
    line
      |> String.split(",")
      |> Enum.map(fn entry -> 
        Regex.run(~r/(\w)(\d+)/, entry)
          |> Enum.drop(1)
          |> List.to_tuple
      end)
      |> Enum.map(fn {direction, distance} -> 
        {direction, String.to_integer(distance)}
      end)
  end

  # def direction_vector(direction)
  def direction_vector("R"), do: {+1, 0}
  def direction_vector("L"), do: {-1, 0}
  def direction_vector("U"), do: {0, -1}
  def direction_vector("D"), do: {0, +1}

  # returns a list of points on that wire (e.g. [{1,1}, {1,2}, {1,3}, {2,3}])
  # mind that the last point on the path is the first in the returned list
  def points(wire) do
    points(wire, [{0, 0}])
  end

  def points([], points), do: points

  # def points([segment | wire], [position | points])
  def points([{direction, distance} | wire], [{px, py} = position | points]) do
    {dx, dy} = direction_vector(direction)
    segment_points = for x <- (dx*distance)..dx, y <- (dy*distance)..dy, do: {px + x, py + y}
    points(wire, segment_points ++ [position | points]) # this could be done more performant
  end

  def with_step_count(points) do
    points
      |> Enum.zip((length(points)-1)..0)
      |> Enum.into(%{}) # if the same points occurs twice, it uses the later one in the list – the one with shorter distance (since the point list is in reverse order)
  end
end

[wire1, wire2] = File.read!("3.txt")
  |> String.split()
  |> Enum.map(&Wire.parse/1)

# wire1 = "R75,D30,R83,U83,L12,D49,R71,U7,L72" |> Wire.parse
# wire2 = "U62,R66,U55,R34,D71,R55,D58,R83" |> Wire.parse

points1 = Wire.points(wire1)
points2 = Wire.points(wire2)

intersections = MapSet.new(points1)
  |> MapSet.intersection(MapSet.new(points2))
  |> MapSet.delete({0,0})

# solution for first puzzle
intersections
  |> Enum.map(fn {px, py} -> abs(px) + abs(py) end) # determine distance
  |> Enum.min
  |> IO.inspect
# => 308

# transform points into a map, mapping point to distance
point_to_step_count1 = Wire.with_step_count(points1)
point_to_step_count2 = Wire.with_step_count(points2)

intersections
  |> Enum.reduce(1000000, fn point, acc -> min(acc, point_to_step_count1[point] + point_to_step_count2[point]) end)
  |> IO.inspect
