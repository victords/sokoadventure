require 'minigl'

include MiniGL

class Enemy < MovableObject
  MOVE_INTERVAL = 60

  attr_accessor :dir, :timer

  def initialize(x, y, area)
    super(x, y, "#{area}_enemy", 3, 1)
    @timer = 0
    @dir = 0
  end

  def update(level)
    animate([0, 1, 2, 1], 12)

    @timer += 1
    if @timer == MOVE_INTERVAL
      level.enemy_move(self)
      @timer = 0
    end

    level.check_man(self)
  end

  def draw
    super(nil, 1, 1, 255, 0xffffff, nil, nil, 1)
  end
end
