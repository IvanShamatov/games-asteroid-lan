class Bullet
  attr_accessor :position, :color

  def initialize(position:, color:)
    @position = position
    @color = color
  end

  def draw
    DrawCircleV(position, 5, color)
  end
end
