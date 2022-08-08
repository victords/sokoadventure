require 'minigl'
require_relative 'constants'

include MiniGL

class Menu
  class MainButton < Button
    attr_reader :highlight

    def initialize(y:, text_id:, icon:, &action)
      super(x: 285, y: y, font: Game.big_font, text: Game.text(text_id), img: :button, center_x: false, margin_x: 70, margin_y: -4, &action)
      @text_id = text_id
      @icon = Res.img(icon)
      @action = lambda do |_|
        action.call
        Game.play_sound(:click)
      end
      @highlight = Res.img(:btnHighlight)
    end

    def update_text
      @text = Game.text(@text_id)
    end

    def draw(alpha = 255, z_index = 0, color = 0xffffff)
      super
      @icon.draw(@x - 5, @y - 5, z_index)
    end
  end

  class LevelButton < Button
    attr_reader :highlight

    def initialize(x:, y:, number:)
      super(x: x, y: y, font: Game.big_font, text: number.to_s, img: :button3, margin_x: -5, margin_y: -4) do
        Game.play_sound(:click)
        Game.start(number)
      end
      @highlight = Res.img(:btn3Highlight)
    end
  end

  class OptionButton < Button
    attr_reader :highlight

    def initialize(x, y, img, &action)
      super(x: x, y: y, img: img, &action)
      @highlight = Res.img("#{img}Highlight")
    end
  end

  def initialize
    @bg = Res.img(:menu)
    @panel = Res.img(:panel)
    @text_helper = TextHelper.new(Game.font)

    back_btn = MainButton.new(y: 540, text_id: :back, icon: :back) do
      set_state(:main)
    end
    @btns = {
      main: [
        MainButton.new(y: 260, text_id: :play, icon: :play) do
          set_state(:play)
        end,
        MainButton.new(y: 320, text_id: :instructions, icon: :help) do
          set_state(:instructions)
        end,
        MainButton.new(y: 380, text_id: :high_scores, icon: :trophy) do
          set_state(:high_scores)
        end,
        MainButton.new(y: 440, text_id: :options, icon: :options) do
          set_state(:options)
        end,
        MainButton.new(y: 500, text_id: :exit, icon: :exit) do
          G.window.close
        end,
      ],
      play: (0...Game.last_level).map do |i|
        LevelButton.new(x: 55 + (i % 10) * 70, y: 240 + (i / 10) * 60, number: i + 1)
      end.push(back_btn),
      instructions: [back_btn],
      high_scores: [back_btn],
      options: [
        OptionButton.new(500, 280, :change) do
          Game.toggle_full_screen
          Game.play_sound(:click)
        end,
        OptionButton.new(500, 320, :change) do
          Game.next_language
          update_button_texts
          Game.play_sound(:click)
        end,
        OptionButton.new(500, 367, :less) do
          Game.change_music_volume(-1)
          Game.play_sound(:click)
        end,
        OptionButton.new(522, 367, :more) do
          Game.change_music_volume(1)
          Game.play_sound(:click)
        end,
        OptionButton.new(500, 407, :less) do
          Game.change_sound_volume(-1)
          Game.play_sound(:click)
        end,
        OptionButton.new(522, 407, :more) do
          Game.change_sound_volume(1)
          Game.play_sound(:click)
        end,
        MainButton.new(y: 540, text_id: :back, icon: :back) do
          Game.save_config
          set_state(:main)
        end,
      ],
    }
    @btn_index = 0
    @state = :main

    Game.play_song(:theme)
  end

  def set_state(state)
    @state = state
    @btn_index = 0
  end

  def update_button_texts
    @btns.each do |_, btns|
      btns.each do |btn|
        btn.update_text if btn.respond_to?(:update_text)
      end
    end
  end

  def update
    if Game.key_press?(:confirm) || KB.key_pressed?(Gosu::KB_RETURN)
      @btns[@state][@btn_index].click
    elsif @state != :main && (Game.key_press?(:cancel) || Game.key_press?(:quit))
      set_state(:main)
    elsif Game.key_press?(:up, true)
      @btn_index -= 1
      @btn_index = @btns[@state].size - 1 if @btn_index < 0
    elsif Game.key_press?(:down, true)
      @btn_index += 1
      @btn_index = 0 if @btn_index >= @btns[@state].size
    end
    @btns[@state].each(&:update)
  end

  def draw
    @bg.draw(0, 0, 0)
    @panel.draw(220, 245, 0) if @state != :main && @state != :play

    case @state
    when :instructions
      @text_helper.write_breaking(Game.text(:help_text), 255, 285, 290)
    when :high_scores
      Game.font.draw_text(Game.text(:from_level), 260, 230, 0, 1, 1, 0xff000000)
      Game.font.draw_text(Game.text(:to_level), 360, 230, 0, 1, 1, 0xff000000)
      Game.font.draw_text(Game.text(:in_tries), 460, 230, 0, 1, 1, 0xff000000)
      (0..4).each do |i|
        (0..2).each do |j|
          text = Game.scores[i] ? Game.scores[i][j].to_s : '-'
          if j == 1 && Game.scores[i] && Game.scores[i][j] == LEVEL_COUNT + 1
            text = Game.text(:end)
          end
          Game.font.draw_text(text, 260 + j * 100, 275 + i * 40, 0, 1, 1, 0xff000000)
        end
      end
    when :options
      Game.font.draw_text(Game.text(Game.full_screen ? :full_screen : :window), 255, 290, 0, 1, 1, 0xff000000)
      Game.font.draw_text(Game.text(:lang_name), 255, 330, 0, 1, 1, 0xff000000)
      Game.font.draw_text("#{Game.text(:music_volume)}: #{Game.music_volume}", 255, 370, 0, 1, 1, 0xff000000)
      Game.font.draw_text("#{Game.text(:sound_volume)}: #{Game.sound_volume}", 255, 410, 0, 1, 1, 0xff000000)
    end

    @btns[@state].each_with_index do |b, i|
      b.draw
      b.highlight.draw(b.x - 2, b.y - 2, 1) if i == @btn_index
    end
  end
end
