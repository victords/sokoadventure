require 'minigl'
require_relative 'game'

class Window < MiniGL::GameWindow
  include MiniGL

  def initialize
    super(800, 600)
    self.caption = 'SokoAdventure'

    Res.prefix = File.expand_path(__FILE__).split('/')[..-3].join('/') + '/data'
    Game.initialize
  end

  def needs_cursor?
    true
  end

  def update
    KB.update
    Mouse.update
    Game.update
  end

  def draw
    Game.draw
  end
end

Window.new.show
