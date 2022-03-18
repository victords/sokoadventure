require 'minigl'
require_relative 'game'

class Window < MiniGL::GameWindow
  include MiniGL

  def initialize
    super(800, 600)
    self.caption = 'SokoAdventure'

    Res.prefix = File.expand_path(__FILE__).split('/')[..-3].join('/') + '/data'
    Game.initialize
    @bg = Res.img(:menu)
    @bgm = Res.song(:theme)
    @bgm.play

    @btns = [
      Button.new(x: 280, y: 260, font: Game.big_font, text: Game.text(:play), img: :button, center_x: false, margin_x: 80, center_y: false, margin_y: 12),
      Button.new(x: 280, y: 320, font: Game.big_font, text: Game.text(:instructions), img: :button, center_x: false, margin_x: 80, center_y: false, margin_y: 12),
      Button.new(x: 280, y: 380, font: Game.big_font, text: Game.text(:high_scores), img: :button, center_x: false, margin_x: 80, center_y: false, margin_y: 12),
      Button.new(x: 280, y: 440, font: Game.big_font, text: Game.text(:options), img: :button, center_x: false, margin_x: 80, center_y: false, margin_y: 12),
      Button.new(x: 280, y: 500, font: Game.big_font, text: Game.text(:exit), img: :button, center_x: false, margin_x: 80, center_y: false, margin_y: 12) { close },
    ]
    @btn_imgs = [
      Res.img(:play),
      Res.img(:help),
      Res.img(:trophy),
      Res.img(:options),
      Res.img(:exit),
    ]
  end

  def needs_cursor?
    true
  end

  def update
    KB.update
    Mouse.update

    @btns.each(&:update)
  end

  def draw
    @bg.draw(0, 0, 0)
    @btns.each_with_index do |b, i|
      b.draw
      @btn_imgs[i].draw(b.x + 5, b.y - 5, 0)
    end
  end
end

Window.new.show
