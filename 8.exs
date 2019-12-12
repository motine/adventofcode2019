defmodule Layer do
  @black 0
  @white 1
  @transparent 2

  # how many times does the layer contain the given number
  def occurences(layer, number), do: Enum.count(layer, &(&1 == number))

  # multiply the number of ones with the number of twos
  def one_two_value(layer), do: Layer.occurences(layer, 1) * Layer.occurences(layer, 2) 

  def render(layers)
  def render([layer]), do: layer
  def render([first, second | rest]), do: render([Layer.merge(first, second) | rest])

  # merge two layers
  def merge(first, second) do
    Enum.zip(first, second)
      |> Enum.map(fn {first_pixel, second_pixel} -> merge_pixel(first_pixel, second_pixel) end)
  end

  # return the value for a pixel during merging (the first pixel, except it is transparent)
  def merge_pixel(first_pixel, second_pixel)
  def merge_pixel(@transparent, second_pixel), do: second_pixel
  def merge_pixel(first_pixel, _), do: first_pixel

  # return the character to draw for a pixel value
  def draw_pixel(@black), do: "  "
  def draw_pixel(@white), do: "W "
  def draw_pixel(@transparent), do: "  "

  # draw a layer on the screen
  def draw(layer, width) do
    layer
      |> Enum.map(&draw_pixel/1) # convert to characters
      |> Enum.chunk_every(width) # slice into rows
      |> Enum.map(&Enum.join/1) # convert individual rows to string
      |> Enum.join("\n") # convert to one image
      |> IO.puts
  end
end

layer_width = 25
layer_height = 6
layer_size = layer_width * layer_height

layers = File.read!("8.txt")
  |> String.codepoints
  |> Enum.map(&String.to_integer/1)
  |> Enum.chunk_every(layer_size)

layers
  |> Enum.min_by(fn layer -> Layer.occurences(layer, 0) end) # fewest_0_layer
  |> Layer.one_two_value
  |> IO.inspect
# => 1905

Layer.render(layers)
  |> Layer.draw(layer_width)
# => ACKPZ
#
#      W W       W W     W     W   W W W     W W W W   
#    W     W   W     W   W   W     W     W         W   
#    W     W   W         W W       W     W       W     
#    W W W W   W         W   W     W W W       W       
#    W     W   W     W   W   W     W         W         
#    W     W     W W     W     W   W         W W W W   
