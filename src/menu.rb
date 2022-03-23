require 'minigl'

include MiniGL

class Menu
  class MainButton < Button
    def initialize(y:, text_id:, icon:, &action)
      super(x: 280, y: y, font: Game.big_font, text: Game.text(text_id), img: :button, center_x: false, margin_x: 80, margin_y: -4, &action)
      @text_id = text_id
      @icon = Res.img(icon)
    end

    def update_text
      @text = Game.text(@text_id)
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
    Game.play_song(:theme)

    @panel = Res.img(:panel)
    @text_helper = TextHelper.new(Game.font)

    @btns = {
      main: [
        MainButton.new(y: 260, text_id: :play, icon: :play) do
          @state = :play
        end,
        MainButton.new(y: 320, text_id: :instructions, icon: :help) do
          @state = :instructions
        end,
        MainButton.new(y: 380, text_id: :high_scores, icon: :trophy) do
          @state = :high_scores
        end,
        MainButton.new(y: 440, text_id: :options, icon: :options) do
          @state = :options
        end,
        MainButton.new(y: 500, text_id: :exit, icon: :exit) do
          G.window.close
        end,
      ],
      play: (0...Game.last_level).map do |i|
        LevelButton.new(x: 55 + (i % 10) * 70, y: 240 + (i / 10) * 60, number: i + 1)
      end,
      options: [
        Button.new(500, 280, nil, nil, :change) do
          Game.toggle_full_screen
        end,
        Button.new(500, 320, nil, nil, :change) do
          Game.next_language
          update_button_texts
        end,
        Button.new(500, 367, nil, nil, :less) do
          Game.change_music_volume(-1)
        end,
        Button.new(522, 367, nil, nil, :more) do
          Game.change_music_volume(1)
        end,
        Button.new(500, 407, nil, nil, :less) do
          Game.change_sound_volume(-1)
        end,
        Button.new(522, 407, nil, nil, :more) do
          Game.change_sound_volume(1)
        end,
        MainButton.new(y: 540, text_id: :back, icon: :back) do
          Game.save_config
          @state = :main
        end,
      ],
    }
    @back_btn = MainButton.new(y: 540, text_id: :back, icon: :back) do
      @state = :main
    end
    @state = :main
  end

  def update_button_texts
    @btns.each do |_, btns|
      btns.each do |btn|
        btn.update_text if btn.respond_to?(:update_text)
      end
    end
    @back_btn.update_text
  end

  def update
    @btns[@state]&.each(&:update)
    @back_btn.update if @state != :main && @state != :options
  end

  def draw
    @bg.draw(0, 0, 0)

    if @state != :main
      @panel.draw(220, 245, 0) if @state != :play
      @back_btn.draw if @state != :options
    end

    case @state
    when :instructions
      @text_helper.write_breaking(Game.text(:help_text), 255, 300, 290)
    when :high_scores
      Game.font.draw_text(Game.text(:from_level), 260, 230, 0, 1, 1, 0xff000000)
      Game.font.draw_text(Game.text(:to_level), 360, 230, 0, 1, 1, 0xff000000)
      Game.font.draw_text(Game.text(:in_tries), 460, 230, 0, 1, 1, 0xff000000)
      (0..4).each do |i|
        (0..2).each do |j|
          text = Game.scores[i] ? Game.scores[i][j].to_s : '-'
          if j == 1 && Game.scores[i][j] == Game::LEVEL_COUNT + 1
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

    @btns[@state]&.each(&:draw)
  end
end
