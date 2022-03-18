require 'minigl'

class Window < MiniGL::GameWindow
  include MiniGL

  def initialize
    super(800, 600)
    self.caption = 'SokoAdventure'

    Res.prefix = File.expand_path(__FILE__).split('/')[..-3].join('/') + '/data'
    @bg = Res.img(:menu)
    @bgm = Res.song(:theme)
    @bgm.play
  end

  def needs_cursor?
    true
  end

  def update
    KB.update
    Mouse.update

    close if KB.key_pressed?(Gosu::KB_ESCAPE)
  end

  def draw
    @bg.draw(0, 0, 0)
  end
end

Window.new.show
