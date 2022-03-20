require 'minigl'

include MiniGL

class KeyDoor < Sprite
  attr_reader :type, :color

  def initialize(x, y, code)
    @type = /R|B|Y|G/ =~ code ? :door : :key
    @color = code.downcase
    super(x, y, "#{@type == :door ? 'd' : 'k'}#{@color}")
  end
end
