require 'minigl'
require_relative 'menu'

class Game
  class << self
    include MiniGL

    attr_reader :font, :big_font, :last_level

    def initialize
      @texts = {}
      Dir["#{Res.prefix}/text/*.txt"].each do |f_name|
        lang_name = f_name.split('/')[-1].split('.')[0].to_sym
        @texts[lang_name] = {}
        File.open(f_name) do |f|
          f.read.each_line do |line|
            parts = line.split("\t")
            @texts[lang_name][parts[0].to_sym] = parts[-1].chomp
          end
        end
      end

      @language = @texts.keys[0]
      @last_level = 24

      @font = Res.font(:font, 20)
      @big_font = Res.font(:font, 32)

      @controller = Menu.new
    end

    def text(key)
      @texts[@language][key] || '<!>'
    end

    def start(level)
      puts "starting level #{level}"
    end

    def update
      @controller.update
    end

    def draw
      @controller.draw
    end
  end
end
