require 'minigl'
require_relative 'constants'

include MiniGL

class Presentation
  def initialize
    @logo = Res.img(:minigl)
    @timer = 0

    Game.play_song(:theme)
  end

  def update
    @timer += 1
    if Game.key_press?(:confirm) ||
      Game.key_press?(:pause) ||
      Game.key_press?(:quit) ||
      Mouse.button_pressed?(:left) ||
      @timer == 420
      Game.open_menu
    end
  end

  def draw
    if @timer <= 195
      alpha = if @timer <= 30
                ((@timer.to_f / 30) * 255).round
              elsif @timer <= 165
                255
              else
                (((195 - @timer).to_f / 30) * 255).round
              end
      color = (alpha << 24) | 0xffffff
      @logo.draw((SCREEN_WIDTH - @logo.width) / 2, (SCREEN_HEIGHT - @logo.height) / 2, 0, 1, 1, color)
      Game.big_font.draw_text_rel(Game.text(:powered_by), SCREEN_WIDTH / 2, (SCREEN_HEIGHT - @logo.height) / 2 - 80, 0, 0.5, 0, 1, 1, color)
    else
      alpha = if @timer <= 225
                (((@timer - 195).to_f / 30) * 255).round
              else
                255
              end
      color = (alpha << 24) | 0xffffff
      Game.big_font.draw_text_rel(Game.text(:game_by), SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 - 60, 0, 0.5, 0, 1, 1, color)
      Game.big_font.draw_text_rel('Victor David Santos', SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2 - 20, 0, 0.5, 0, 2, 2, color)
    end
  end
end
