require 'minigl'

include MiniGL

class Ball < Sprite
  attr_reader :set

  def initialize(x, y, area)
    super(x, y, "#{area}_ballAim", 3, 1)
    @unset = Res.img("#{area}_ball")
  end

  def update
    return unless @set

    animate([0, 1, 2, 1], 12)
  end

  def move(x_var, y_var, set)
    @x += x_var
    @y += y_var
    @set = set
  end

  def draw
    if @set
      super()
    else
      @unset.draw(@x, @y, 0)
    end
  end
end