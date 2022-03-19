require 'minigl'

include MiniGL

class Menu
  class MainButton < Button
    def initialize(y:, text:, icon:, &action)
      super(x: 280, y: y, font: Game.big_font, text: Game.text(text), img: :button, center_x: false, margin_x: 80, margin_y: -4, &action)
      @icon = Res.img(icon)
    end

    def draw(alpha = 255, z_index = 0, color = 0xffffff)
      super
      @icon.draw(@x + 5, @y - 5, z_index)
    end
  end

  class LevelButton < Button
    def initialize(x:, y:, number:)
      super(x: x, y: y, font: Game.big_font, text: number.to_s, img: :button3, margin_x: -5, margin_y: -4) do
        Game.start(number)
      end
    end
  end

  def initialize
    @bg = Res.img(:menu)
    @bgm = Res.song(:theme)
    @bgm.play

    @btns = {
      main: [
        MainButton.new(y: 260, text: :play, icon: :play) do
          @state = :play
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
      ],
      play: (0...Game.last_level).map do |i|
        LevelButton.new(x: 55 + (i % 10) * 70, y: 240 + (i / 10) * 60, number: i + 1)
      end.push(
        MainButton.new(y: 540, text: :back, icon: :back) do
          @state = :main
        end
      ),
      instructions: [

      ],
      high_scores: [

      ],
      options: [

      ],
    }
    @state = :main
  end

  def update
    @btns[@state].each(&:update)
  end

  def draw
    @bg.draw(0, 0, 0)
    @btns[@state].each(&:draw)
  end
end
