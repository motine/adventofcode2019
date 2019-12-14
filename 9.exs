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
  
  @doc "is star hidden behind the line segment between from and to?"
  def occludes?(from, to, star)
  def occludes?(p, p, _), do: false
  def occludes?(from, to, star), do: on_line?(from, star, to)

  @doc "is the given point on the line segment between from and to?"
  def on_line?(from, to, point)
  def on_line?(p, p, _), do: false
  def on_line?(from, to, point) do
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
end

ExUnit.start()

defmodule MapTest do
  use ExUnit.Case
  # we can not use doctest here, because I want to work in a single file
  test "occludes?" do
    AstroidMap.occludes?({1,1}, {2,2}, {3,3}) |> assert
    AstroidMap.occludes?({0,0}, {0,1}, {0,4}) |> assert
    AstroidMap.occludes?({1,1}, {3,1}, {5,1}) |> assert
    AstroidMap.occludes?({0,0}, {3,0}, {1,0}) |> refute
    AstroidMap.occludes?({2,2}, {5,2}, {1,2}) |> refute
    AstroidMap.occludes?({1,1}, {1,1}, {0,0}) |> refute
  end
end

