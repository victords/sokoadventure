require 'minigl'
require 'rbconfig'
require 'fileutils'
require_relative 'menu'

class Game
  class << self
    include MiniGL

    attr_reader :font, :big_font, :last_level, :scores

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

      os = RbConfig::CONFIG['host_os']
      @save_dir =
        if /linux/ =~ os
          "#{Dir.home}/.vds-games/sokoadventure"
        else
          "#{Dir.home}/AppData/Local/VDS Games/SokoAdventure"
        end

      FileUtils.mkdir_p(@save_dir) unless File.exist?(@save_dir)
      scores_path = "#{@save_dir}/scores.soko"
      if File.exist?(scores_path)
        File.open(scores_path) do |f|
          @scores = f.read.split('|').map { |entry| entry.split(';').map(&:to_i) }
        end
      else
        @scores = []
        save_scores
      end

      @language = :portuguese
      @last_level = 24

      @font = Res.font(:font, 20)
      @big_font = Res.font(:font, 32)

      @controller = Menu.new
    end

    def text(key)
      (@texts[@language][key] || '<!>').gsub('\\', "\n")
    end

    def start(level)
      puts "starting level #{level}"
    end

    def save_scores
      File.open("#{@save_dir}/scores.soko", 'w+') do |f|
        f.write(@scores.map { |entry| entry.join(';') }.join('|'))
      end
    end

    def update
      @controller.update

      # TODO remove later
      @language = :english if KB.key_pressed?(Gosu::KB_E)
      @language = :portuguese if KB.key_pressed?(Gosu::KB_P)
      @language = :spanish if KB.key_pressed?(Gosu::KB_S)
    end

    def draw
      @controller.draw
    end
  end
end
