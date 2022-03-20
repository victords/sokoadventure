require_relative 'movable_object'

class Box < MovableObject
  def initialize(x, y)
    super(x, y, :box)
  end
end
