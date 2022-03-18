require 'minigl'
require_relative 'game'

include MiniGL

class Menu
  class MainButton < Button
    def initialize(y:, text:, icon:, &action)
      super(x: 280, y: y, font: Game.big_font, text: Game.text(text), img: :button, center_x: false, margin_x: 80, center_y: false, margin_y: 12, &action)
      @icon = Res.img(icon)
    end

    def draw(alpha = 255, z_index = 0, color = 0xffffff)
      super
      @icon.draw(@x + 5, @y - 5, z_index)
    end
  end

  def initialize
    @bg = Res.img(:menu)
    @bgm = Res.song(:theme)
    @bgm.play

    @btns = [
      MainButton.new(y: 260, text: :play, icon: :play) do
        puts 'clicked play'
      end,
      MainButton.new(y: 320, text: :instructions, icon: :help) do
        puts 'clicked help'
      end,
      MainButton.new(y: 380, text: :high_scores, icon: :trophy) do
        puts 'clicked scores'
      end,
      MainButton.new(y: 440, text: :options, icon: :options) do
        puts 'clicked options'
      end,
      MainButton.new(y: 500, text: :exit, icon: :exit) do
        G.window.close
      end,
    ]
  end

  def update
    @btns.each(&:update)
  end

  def draw
    @bg.draw(0, 0, 0)
    @btns.each(&:draw)
  end
end
