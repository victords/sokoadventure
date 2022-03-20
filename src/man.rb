require 'minigl'

include MiniGL

class Man < Sprite
  def initialize(x, y)
    super(x, y, :man, 3, 4)
  end

  def move(x_var, y_var)
    @x += x_var
    @y += y_var
  end

  def update
    animate([0, 1, 2, 1], 12)
  end
end
