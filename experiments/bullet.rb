class Bullet
  BULLET_SPEED = 20
  SIZE = 5

  attr_accessor :pos, :color, :id, :active, :rect

  def initialize(id:, pos:, color:, direction:)
    @pos = pos
    @active = true
    @color = color
    @velocity = Vector2Scale(Vector2Normalize(direction), BULLET_SPEED)
    @id = id
    @rect = Rectangle.create(@pos.x - SIZE , @pos.y - SIZE, 2 * SIZE, 2 * SIZE)
  end

  def draw
    DrawCircleV(pos, SIZE, color)
    DrawRectangleLinesEx(rect, 3, Fade(color, 0.5))
  end

  def update
    @pos = Vector2Add(@pos, @velocity)
    if @pos.x < 0 || @pos.x > FIELD_WIDTH || @pos.y < 0 || @pos.y > FIELD_HEIGHT
      @active = false
    end
    @rect.x, @rect.y = @pos.x, @pos.y
  end
end
