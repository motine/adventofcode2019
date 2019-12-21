# From each star A
#   # of unsecluded stars(A)

# # of unsecluded stars(A):
#   Filter each star B
#     Is secluded(B, from A)

# Is secluded(star, source)
#   Any? Of all stars C
#     Secludes?(star, source, C)

# # is star secluded by behind target when looking from source?
# secludes?(star, source, target)
#     If distance of star to line(source, target) < 0.01 and star behind line(source, target)

defmodule AstroidMap do
  @moduledoc "Parameter such as star, from and to are coordinates of the form {x,y}."
  
  def read(filename) do
    input = File.read!(filename)
      |> String.split
      |> Enum.map(&String.codepoints/1)

    width = length(Enum.at(input, 0))
    height = length(input)

    for y <- 0..(height-1),  x <- 0..(width-1), Enum.at(Enum.at(input, y), x) == "#", do: {x, y} # this is very imperative thinking, could be improved
  end

  @doc "is star hidden behind the line segment between from and to?"
  def occludes?(from, to, star)
  def occludes?(p, p, _), do: false
  def occludes?(_, p, p), do: false
  def occludes?(from, to, star), do: on_segment?(from, star, to)

  @doc "is the given point on the line segment between from and to?"
  def on_segment?(from, to, point)
  def on_segment?(p, p, _), do: false
  def on_segment?(from, to, point) do
    # using this approach: https://stackoverflow.com/a/11908158/4007237
    # see this explanation for more info why this works: http://www.sunshine2k.de/coding/java/PointOnLine/PointOnLine.html
    [{fx,fy}, {tx,ty}, {px,py}] = [from, to, point]
    {dxc, dyc} = {px - fx, py - fy};
    {dxl, dyl} = {tx - fx, ty - fy};
    cross = dxc * dyl - dyc * dxl;
    if cross != 0 do
      false
    else
      if abs(dxl) >= abs(dyl) do
        if dxl > 0, do: fx <= px && px <= tx, else: tx <= px && px <= fx
      else
        if dyl > 0, do: fy <= py && py <= ty, else: ty <= py && py <= fy
      end
    end    
  end

  @doc "can source see the other star? (is there no star between source and other?)"
  def can_see?(source, other, stars) do
    stars
    |> Enum.all?(fn star -> !occludes?(source, star, other) end)
  end

  def visible_star_count(source, stars) do
    Enum.count(stars, fn star -> can_see?(source, star, stars) end) - 1
  end
end

# ExUnit.start()

# defmodule MapTest do
#   use ExUnit.Case
#   import AstroidMap
#   # we can not use doctest here, because I want to work in a single file
#   test "occludes?" do
#     occludes?({1,1}, {2,2}, {3,3}) |> assert
#     occludes?({0,0}, {0,1}, {0,4}) |> assert
#     occludes?({1,1}, {3,1}, {5,1}) |> assert
#     occludes?({0,0}, {3,0}, {1,0}) |> refute
#     occludes?({2,2}, {5,2}, {1,2}) |> refute
#     occludes?({1,1}, {1,1}, {0,0}) |> refute
#   end

#   test "can_see?" do
#     can_see?({1,1}, {3,3}, [{1,1}]) |> assert
#     can_see?({1,1}, {3,3}, [{1,1}, {2,2}]) |> refute
#   end
# end

stars = AstroidMap.read("10.txt")

stars
  |> Enum.map(fn star -> AstroidMap.visible_star_count(star, stars) end)
  |> Enum.max
  |> IO.inspect

