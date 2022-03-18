require 'minigl'

class Game
  class << self
    include MiniGL

    attr_reader :font, :big_font

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

      @font = Res.font(:font, 20)
      @big_font = Res.font(:font, 32)
    end

    def text(key)
      @texts[@language][key] || '<!>'
    end
  end
end
