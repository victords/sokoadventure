require 'minigl'

include MiniGL

class Man < Sprite
  def initialize(x, y)
    super(x, y, :man, 3, 4)
  end

  def update
    animate([0, 1, 2, 1], 12)
  end
end
