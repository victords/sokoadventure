require_relative 'movable_object'

class Man < MovableObject
  attr_reader :dir

  def initialize(x, y)
    super(x, y, :man, 3, 4)
    @img_index = 3
    @indices = [3, 4, 5, 4]
    @dir = 2
  end

  def set_dir(dir)
    @dir = dir
    @indices = case dir
               when 0 then [0, 1, 2, 1]
               when 1 then [9, 10, 11, 10]
               when 2 then [3, 4, 5, 4]
               else        [6, 7, 8, 7]
               end
    set_animation(@indices[0])
  end

  def update
    animate(@indices, 12)
  end

  def draw
    super(nil, 1, 1, 255, 0xffffff, nil, nil, 2)
  end
end
