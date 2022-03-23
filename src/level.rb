require_relative 'constants'
require_relative 'man'
require_relative 'ball'
require_relative 'door'
require_relative 'box'
require_relative 'enemy'
require_relative 'text_effect'

include MiniGL

class Level
  EFFECT_DURATION = 150

  attr_reader :number

  class MenuButton < Button
    def initialize(x, y, text_id, sh_key, sh_key_text, &action)
      super(x: x, y: y, font: Game.font, text: "#{Game.text(text_id)} (#{sh_key_text})", img: :button2, &action)
      @sh_key = sh_key
      @sh_key_text = sh_key_text
      @action = lambda do |_|
        action.call
        Game.play_sound(:click)
      end
    end

    def update
      super
      @action.call(@params) if @enabled && KB.key_pressed?(@sh_key)
    end

    def change_text(text_id)
      @text = "#{Game.text(text_id)} (#{@sh_key_text})"
      set_position(@x, @y)
    end
  end

  def initialize(number)
    @number = number
    @area_name =
      case (number - 1) / 10
      when 0 then :room
      when 1 then :forest
      when 2 then :desert
      when 3 then :snow
      when 4 then :cave
      end

    @bg = Res.img("#{@area_name}_back", false, true)
    @tile_floor = Res.img("#{@area_name}_ground", false, true)
    @tile_wall = Res.img("#{@area_name}_block", false, true)
    @tile_aim = Res.img("#{@area_name}_aim", false, true)
    @holes = Res.imgs(:holeset, 4, 4, false, '.png', nil, true)
    @set_box = Res.img(:box2)
    @lock = Res.img(:lock)
    @key_imgs = {
      r: Res.img(:kr),
      b: Res.img(:kb),
      y: Res.img(:ky),
      g: Res.img(:kg),
    }

    border = Res.img("#{@area_name}_border")
    @borders = [
      border.subimage(0, 0, 12, 12),   # top left
      border.subimage(12, 0, 32, 12),  # top
      border.subimage(44, 0, 12, 12),  # top right
      border.subimage(0, 12, 12, 32),  # left
      border.subimage(44, 12, 12, 32), # right
      border.subimage(0, 44, 12, 12),  # bottom left
      border.subimage(12, 44, 32, 12), # bottom
      border.subimage(44, 44, 12, 12), # bottom right
    ]

    @text_helper = TextHelper.new(Game.font)
    @text_helper_big = TextHelper.new(Game.big_font)

    @buttons = [
      (@pause_button = MenuButton.new(690, 10, :pause, Gosu::KB_SPACE, '_') do
        @paused = !@paused
        @pause_button.change_text(@paused ? :resume : :pause)
        @undo_button.enabled = !@paused
      end),
      (@undo_button = MenuButton.new(690, 55, :undo, Gosu::KB_Z, 'Z') do
        undo
      end),
      MenuButton.new(690, 100, :restart, Gosu::KB_R, 'R') do
        @confirmation = :restart
      end,
      MenuButton.new(690, 145, :quit, Gosu::KB_ESCAPE, 'Esc') do
        @confirmation = :quit
      end,
    ]

    @panel = Res.img(:panel)
    @confirm_buttons = [
      MenuButton.new(295, 340, :yes, Gosu::KB_Q, 'Q') do
        if @confirmation == :restart
          Game.register_attempt
          start
        elsif @confirmation == :quit
          Game.quit
        end
      end,
      MenuButton.new(405, 340, :no, Gosu::KB_W, 'W') do
        @confirmation = nil
      end
    ]

    start
    Game.play_song(@area_name)
  end

  def start
    @confirmation = nil
    @effect = nil
    @effect_timer = 0
    if @paused
      @paused = false
      @pause_button.change_text(:pause)
      @undo_button.enabled = true
    end

    @aim_count = 0
    @set_count = 0
    @key_count = {
      r: 0,
      b: 0,
      y: 0,
      g: 0
    }
    @history = []

    File.open("#{Res.prefix}levels/lvl#{@number}") do |f|
      lines = f.read.split("\n")
      @start_col = lines[0].to_i
      @start_row = lines[1].to_i
      @width = lines[2].size
      @height = lines.size - 2
      @margin_x = (SCREEN_WIDTH - TILE_SIZE * @width) / 2
      @margin_y = (SCREEN_HEIGHT - TILE_SIZE * @height) / 2

      @tiles = Array.new(@width) {
        Array.new(@height)
      }
      @objects = Array.new(@width) {
        Array.new(@height) { [] }
      }
      @enemies = []
      lines[2..-1].each_with_index do |l, j|
        break if l.empty?

        l.each_char.with_index do |c, i|
          case c
          when /o|\+/
            @objects[i][j] << Ball.new(@margin_x + i * TILE_SIZE, @margin_y + j * TILE_SIZE, @area_name, c == '+')
          when /R|B|Y|G/
            @objects[i][j] << Door.new(@margin_x + i * TILE_SIZE, @margin_y + j * TILE_SIZE, c.downcase)
          when 'c'
            @objects[i][j] << Box.new(@margin_x + i * TILE_SIZE, @margin_y + j * TILE_SIZE)
          when 'e'
            @objects[i][j] << (enemy = Enemy.new(@margin_x + i * TILE_SIZE, @margin_y + j * TILE_SIZE, @area_name))
            @enemies << enemy
          end
          if c == '+'
            @set_count += 1
            c = 'x'
          end
          @aim_count += 1 if c == 'x'
          @tiles[i][j] = c
        end
      end
    end

    @man = Man.new(@margin_x + @start_col * TILE_SIZE, @margin_y + @start_row * TILE_SIZE)
  end

  def player_move(i, j, i_var, j_var)
    n_i = i + i_var
    n_j = j + j_var
    return if n_i < 0 || n_i >= @width || n_j < 0 || n_j >= @height
    return if @tiles[n_i][n_j] == '#' || @tiles[n_i][n_j] == 'h'

    step = {}
    objs = @objects[n_i][n_j]
    nn_i = n_i + i_var
    nn_j = n_j + j_var
    blocked = false
    objs.each do |obj|
      case obj
      when Ball
        break blocked = true if obstacle_at?(nn_i, nn_j)
        break blocked = true if @tiles[n_i][n_j] == 'l' || @tiles[nn_i][nn_j] == 'h'

        will_set = @tiles[nn_i][nn_j] == 'x'
        if will_set && !obj.set
          @set_count += 1
          step[:set_change] = 1
        elsif !will_set && obj.set
          @set_count -= 1
          step[:set_change] = -1
        end

        @objects[n_i][n_j].delete(obj)
        @objects[nn_i][nn_j] << obj
        obj.move(i_var * TILE_SIZE, j_var * TILE_SIZE, will_set)
        step[:obj_move] = {
          obj: obj,
          from: [n_i, n_j],
          to: [nn_i, nn_j],
          ball: true
        }
        Game.play_sound(:push)
      when Door
        if @key_count[obj.color] > 0
          @objects[n_i][n_j].delete(obj)
          @key_count[obj.color] -= 1
          step[:obj_remove] = {
            obj: obj,
            from: [n_i, n_j]
          }
          step[:key_use] = obj.color
          Game.play_sound(:open)
        else
          break blocked = true
        end
      when Box
        break blocked = true if obstacle_at?(nn_i, nn_j, false)
        break blocked = true if @tiles[n_i][n_j] == 'l'

        @objects[n_i][n_j].delete(obj)
        if @tiles[nn_i][nn_j] == 'h'
          @tiles[nn_i][nn_j] = 'H'
          step[:obj_remove] = {
            obj: obj,
            from: [n_i, n_j]
          }
          step[:hole_cover] = [nn_i, nn_j]
        else
          @objects[nn_i][nn_j] << obj
          obj.move(i_var * TILE_SIZE, j_var * TILE_SIZE)
          step[:obj_move] = {
            obj: obj,
            from: [n_i, n_j],
            to: [nn_i, nn_j]
          }
        end
        Game.play_sound(:push)
      end
    end
    return if blocked

    if /r|b|y|g/ =~ @tiles[n_i][n_j]
      color = @tiles[n_i][n_j].to_sym
      @key_count[color] += 1
      @tiles[n_i][n_j] = '.'
      step[:key_add] = {
        color: color,
        from: [n_i, n_j]
      }
    end

    @man.move(i_var * TILE_SIZE, j_var * TILE_SIZE)
    step[:player] = [i, j, @man.dir]
    step[:enemies] = @enemies.map { |e| [e.x, e.y, e.dir, e.timer] }
    @history << step
  end

  def enemy_move(enemy)
    tries = 0
    i = (enemy.x - @margin_x) / TILE_SIZE
    j = (enemy.y - @margin_y) / TILE_SIZE
    while tries < 4
      i_var, j_var =
        case enemy.dir
        when 0 then [0, -1]
        when 1 then [1, 0]
        when 2 then [0, 1]
        else        [-1, 0]
        end
      if obstacle_at?(i + i_var, j + j_var)
        tries += 1
        enemy.dir = (enemy.dir + tries) % 4
      else
        @objects[i][j].delete(enemy)
        @objects[i + i_var][j + j_var] << enemy
        enemy.move(i_var * TILE_SIZE, j_var * TILE_SIZE)
        break
      end
    end
  end

  def check_man(enemy)
    i = (enemy.x - @margin_x) / TILE_SIZE
    j = (enemy.y - @margin_y) / TILE_SIZE
    m_i = (@man.x - @margin_x) / TILE_SIZE
    m_j = (@man.y - @margin_y) / TILE_SIZE
    if i == m_i && j == m_j
      @effect = TextEffect.new(:try_again, 0xff6666)
    end
  end

  def obstacle_at?(i, j, check_hole = true)
    return true if i < 0 || i >= @width || j < 0 || j >= @height
    return true if @tiles[i][j] == '#'
    return true if check_hole && @tiles[i][j] == 'h'

    objs = @objects[i][j]
    objs.any? do |obj|
      obj.is_a?(Ball) || obj.is_a?(Box) || obj.is_a?(Door)
    end
  end

  def undo
    return if @history.empty?

    step = @history.pop

    @set_count -= step[:set_change] if step[:set_change]

    if step[:obj_move]
      obj = step[:obj_move][:obj]
      from = [step[:obj_move][:from][0], step[:obj_move][:from][1]]
      to = [step[:obj_move][:to][0], step[:obj_move][:to][1]]
      @objects[to[0]][to[1]].delete(obj)
      @objects[from[0]][from[1]] << obj
      if step[:obj_move][:ball]
        obj.move((from[0] - to[0]) * TILE_SIZE, (from[1] - to[1]) * TILE_SIZE, @tiles[from[0]][from[1]] == 'x')
      else
        obj.move((from[0] - to[0]) * TILE_SIZE, (from[1] - to[1]) * TILE_SIZE)
      end
    end

    if step[:obj_remove]
      obj = step[:obj_remove][:obj]
      @objects[step[:obj_remove][:from][0]][step[:obj_remove][:from][1]] << obj
    end

    @key_count[step[:key_use]] += 1 if step[:key_use]

    if step[:hole_cover]
      @tiles[step[:hole_cover][0]][step[:hole_cover][1]] = 'h'
    end

    if step[:key_add]
      @key_count[step[:key_add][:color]] -= 1
      @tiles[step[:key_add][:from][0]][step[:key_add][:from][1]] = step[:key_add][:color].to_s
    end

    @enemies.each_with_index do |e, ind|
      i = (e.x - @margin_x) / TILE_SIZE
      j = (e.y - @margin_y) / TILE_SIZE
      @objects[i][j].delete(e)
      e.x = step[:enemies][ind][0]
      e.y = step[:enemies][ind][1]
      i = (e.x - @margin_x) / TILE_SIZE
      j = (e.y - @margin_y) / TILE_SIZE
      @objects[i][j] << e

      e.dir = step[:enemies][ind][2]
      e.timer = step[:enemies][ind][3]
    end

    @man.x = @margin_x + step[:player][0] * TILE_SIZE
    @man.y = @margin_y + step[:player][1] * TILE_SIZE
    @man.set_dir(step[:player][2])
  end

  def congratulate
    @effect = TextEffect.new(:congratulations, 0xcccc00)
    @effect_timer = -150
  end

  def update
    if @confirmation
      @confirm_buttons.each(&:update)
    elsif @effect
      @effect.update
      @effect_timer += 1
      if @effect_timer == EFFECT_DURATION
        case @effect.type
        when :won
          Game.next_level
        when :try_again
          Game.register_attempt
          start
        when :congratulations
          Game.quit
        end
      end
    else
      @buttons.each(&:update)
    end
    return if @confirmation || @effect || @paused

    prev_count = @set_count

    i = (@man.x - @margin_x) / TILE_SIZE
    j = (@man.y - @margin_y) / TILE_SIZE
    if KB.key_pressed?(Gosu::KB_UP) || KB.key_held?(Gosu::KB_UP)
      player_move(i, j, 0, -1)
      @man.set_dir(0)
    elsif KB.key_pressed?(Gosu::KB_RIGHT) || KB.key_held?(Gosu::KB_RIGHT)
      player_move(i, j, 1, 0)
      @man.set_dir(1)
    elsif KB.key_pressed?(Gosu::KB_DOWN) || KB.key_held?(Gosu::KB_DOWN)
      player_move(i, j, 0, 1)
      @man.set_dir(2)
    elsif KB.key_pressed?(Gosu::KB_LEFT) || KB.key_held?(Gosu::KB_LEFT)
      player_move(i, j, -1, 0)
      @man.set_dir(3)
    end

    @objects.flatten.each do |obj|
      obj.update(self) if obj.respond_to?(:update)
    end
    @man.update

    if !@effect && prev_count < @aim_count && @set_count == @aim_count
      @effect = TextEffect.new(:won, 0xffffff)
      Game.play_sound(:clear)
    end
  end

  def get_hole(i, j)
    up = j > 0 && /h/i =~ @tiles[i][j - 1]
    rt = i < @width - 1 && /h/i =~ @tiles[i + 1][j]
    dn = j < @height - 1 && /h/i =~ @tiles[i][j + 1]
    lf = i > 0 && /h/i =~ @tiles[i - 1][j]
    return 10 if up && rt && dn && lf
    return 2 if up && rt && dn
    return 6 if up && rt && lf
    return 7 if up && dn && lf
    return 3 if rt && dn && lf
    return 4 if up && rt
    return 14 if up && dn
    return 5 if up && lf
    return 0 if rt && dn
    return 11 if rt && lf
    return 1 if dn && lf
    return 13 if up
    return 12 if rt
    return 8 if dn
    return 9 if lf
    15
  end

  def draw
    (0..3).each do |i|
      (0..2).each do |j|
        @bg.draw(i * 200, j * 200, 0)
      end
    end

    @borders[0].draw(@margin_x - 12, @margin_y - 12, 0)
    @borders[2].draw(SCREEN_WIDTH - @margin_x, @margin_y - 12, 0)
    @borders[5].draw(@margin_x - 12, SCREEN_HEIGHT - @margin_y, 0)
    @borders[7].draw(SCREEN_WIDTH - @margin_x, SCREEN_HEIGHT - @margin_y, 0)
    (0...@width).each do |i|
      x = @margin_x + i * TILE_SIZE
      @borders[1].draw(x, @margin_y - 12, 0)
      @borders[6].draw(x, SCREEN_HEIGHT - @margin_y, 0)
      (0...@height).each do |j|
        y = @margin_y + j * TILE_SIZE

        if i == 0
          @borders[3].draw(@margin_x - 12, y, 0)
          @borders[4].draw(SCREEN_WIDTH - @margin_x, y, 0)
        end

        @tile_floor.draw(x, y, 0)
        tile = @tiles[i][j]
        overlay =
          case tile
          when '#' then @tile_wall
          when 'x' then @tile_aim
          when /r|b|y|g/ then @key_imgs[tile.to_sym]
          when /h/i then @holes[get_hole(i, j)]
          when 'l' then @lock
          end
        overlay&.draw(x, y, 0)
        @set_box.draw(x, y, 0) if tile == 'H'
      end
    end

    @objects.flatten.each(&:draw)
    @man.draw

    @text_helper_big.write_line("#{Game.text(:level)} #{@number}", 10, 10, :left, 0xffffff, 255, :shadow)
    @key_imgs[:r].draw(10, 50, 0, 0.5, 0.5)
    @text_helper.write_line(@key_count[:r], 36, 50, :left, 0xff0000, 255, :shadow)
    @key_imgs[:b].draw(10, 70, 0, 0.5, 0.5)
    @text_helper.write_line(@key_count[:b], 36, 70, :left, 0x0000ff, 255, :shadow)
    @key_imgs[:y].draw(10, 90, 0, 0.5, 0.5)
    @text_helper.write_line(@key_count[:y], 36, 90, :left, 0xcccc00, 255, :shadow)
    @key_imgs[:g].draw(10, 110, 0, 0.5, 0.5)
    @text_helper.write_line(@key_count[:g], 36, 110, :left, 0x008000, 255, :shadow)

    @buttons.each(&:draw)

    if @confirmation
      G.window.draw_quad(0, 0, 0x80000000,
                         SCREEN_WIDTH, 0, 0x80000000,
                         0, SCREEN_HEIGHT, 0x80000000,
                         SCREEN_WIDTH, SCREEN_HEIGHT, 0x80000000, 100)
      @panel.draw((SCREEN_WIDTH - @panel.width) / 2, (SCREEN_HEIGHT - @panel.height) / 2, 100)
      @text_helper_big.write_line(Game.text(@confirmation), 400, 210, :center, 0, 255, nil, 0, 0, 0, 100)
      @text_helper.write_line(Game.text(:are_you_sure), 400, 275, :center, 0, 255, nil, 0, 0, 0, 100)
      @confirm_buttons.each { |b| b.draw(255, 100) }
    elsif @effect
      @effect.draw
    end
  end
end
