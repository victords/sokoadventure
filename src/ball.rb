require 'minigl'

include MiniGL

class Ball < Sprite
  def initialize(x, y, area)
    super(x, y, "#{area}_ballAim", 3, 1)
    @unset = Res.img("#{area}_ball")
  end

  def draw(map = nil, scale_x = nil, scale_y = nil, alpha = nil, color = nil, angle = nil, flip = nil, z_index = nil, round = nil)
    if @set
      super
    else
      @unset.draw(@x, @y, 0)
    end
  end
end
