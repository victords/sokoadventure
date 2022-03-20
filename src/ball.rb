require_relative 'movable_object'

class Ball < MovableObject
  attr_reader :set

  def initialize(x, y, area, set)
    super(x, y, "#{area}_ballAim", 3, 1)
    @set = set
    @unset_img = Res.img("#{area}_ball")
  end

  def update
    return unless @set

    animate([0, 1, 2, 1], 12)
  end

  def move(x_var, y_var, set)
    super(x_var, y_var)
    @set = set
  end

  def draw
    if @set
      super
    else
      @unset_img.draw(@x, @y, 0)
    end
  end
end
