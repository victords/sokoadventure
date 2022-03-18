require 'minigl'
require_relative 'menu'

class Window < MiniGL::GameWindow
  include MiniGL

  def initialize
    super(800, 600)
    self.caption = 'SokoAdventure'

    Res.prefix = File.expand_path(__FILE__).split('/')[..-3].join('/') + '/data'
    Game.initialize

    @controller = Menu.new
  end

  def needs_cursor?
    true
  end

  def update
    KB.update
    Mouse.update
    @controller.update
  end

  def draw
    @controller.draw
  end
end

Window.new.show
