require 'minigl'
require_relative 'constants'

include MiniGL

class TextEffect
  attr_reader :type

  def initialize(type, color)
    @type = type
    @text = Game.text(type)
    @color = color
    @x = -300
    @y = (SCREEN_HEIGHT - Game.big_font.height) / 2
    @text_helper = TextHelper.new(Game.big_font)
  end

  def update
    d_x = SCREEN_WIDTH / 2 - @x
    return if d_x == 0

    if d_x <= 1
      @x = SCREEN_WIDTH / 2
      return
    end

    @x += d_x * 0.1
  end

  def draw
    @text_helper.write_line(@text, @x, @y, :center, @color, 255, :shadow, 0, 2, 255, 99)
  end
end
