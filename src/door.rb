require 'minigl'

include MiniGL

class Door < Sprite
  attr_reader :color

  def initialize(x, y, color)
    @color = color.to_sym
    super(x, y, "d#{color}")
  end
end
