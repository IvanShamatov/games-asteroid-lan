class Asteroid
  attr_reader :pos, :rect, :size
  MAX_SIZE = 80
  MIN_SIZE = 30

  def initialize(x, y)
    @pos = Vector2.create(x, y)
    @color = [GOLD, YELLOW, RED, WHITE].sample
    @size = rand(MIN_SIZE..MAX_SIZE)
    @rect = Rectangle.create(@pos.x - @size, @pos.y - @size, 2* @size, 2* @size)
  end

  def draw
    DrawPolyLinesEx(pos, 5, @size, 0, 5, Fade(@color, 0.5))
    # DrawCircleLinesV(pos, @size, Fade(@color, 0.5))
    # DrawRectangleLinesEx(rect, 3, Fade(@color, 0.5))
  end
end
