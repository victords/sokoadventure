require 'minigl'

include MiniGL

class MovableObject < Sprite
  def move(x_var, y_var)
    @x += x_var
    @y += y_var
  end
end
