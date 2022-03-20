require_relative 'constants'
require_relative 'ball'
require_relative 'man'

class Level
  def initialize(number)
    area_name =
      case (number - 1) / 10
      when 0 then :room
      when 1 then :forest
      when 2 then :desert
      when 3 then :snow
      when 4 then :cave
      end

    File.open("#{Res.prefix}levels/lvl#{number}") do |f|
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
        Array.new(@height)
      }
      lines[2..-1].each_with_index do |l, j|
        break if l.empty?

        l.each_char.with_index do |c, i|
          if c == 'o'
            @objects[i][j] = Ball.new(@margin_x + i * TILE_SIZE, @margin_y + j * TILE_SIZE, area_name)
          end
          @tiles[i][j] = c == 'o' ? '.' : c
        end
      end
    end

    @man = Man.new(@margin_x + @start_col * TILE_SIZE, @margin_y + @start_row * TILE_SIZE)

    @bg = Res.img("#{area_name}_back", false, true)
    @tile_floor = Res.img("#{area_name}_ground", false, true)
    @tile_wall = Res.img("#{area_name}_block")
    @tile_aim = Res.img("#{area_name}_aim")

    border = Res.img("#{area_name}_border")
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

    Game.play_song(area_name)
  end

  def update
    @man.update
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
        overlay =
          case @tiles[i][j]
          when '#' then @tile_wall
          when 'x' then @tile_aim
          end
        overlay&.draw(x, y, 0)
      end
    end

    @objects.each do |col|
      col.each do |obj|
        obj&.draw
      end
    end

    @man.draw
  end
end
