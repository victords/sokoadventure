require 'minigl'
require_relative 'game'
require_relative 'constants'

class Window < MiniGL::GameWindow
  include MiniGL

  def initialize
    Game.load
    super(SCREEN_WIDTH, SCREEN_HEIGHT, Game.full_screen)
    G.kb_held_delay = 5
    self.caption = 'SokoAdventure'

    Res.prefix = File.expand_path(__FILE__).split('/')[..-3].join('/') + '/data'
    Game.initialize
  end

  def needs_cursor?
    true
  end

  def gamepad_connected(_index)
    Game.toggle_gamepad(true)
  end

  def gamepad_disconnected(_index)
    Game.toggle_gamepad(false)
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
