class Enemy
  PLAYER_ROT_SPEED = 4.0
  PLAYER_ACCELERATION = 30
  PLAYER_DECELERATION = 0.2
  MAX_SPEED = 5
  SIZE = 30

  attr_reader :id

  attr_accessor :health, :pos, :rotation, :velocity, :color, :score, :rect

  def initialize(id:, pos:)
    @id = id
    @health = 100
    @pos = pos
    @rotation = 0
    @velocity = Vector2Scale(Vector2.create(2 * rand() - 1, 2 * rand() - 1), MAX_SPEED)
    @color = [WHITE, GREEN, GOLD, SKYBLUE, RED].sample
    @score = 0
    @rect = Rectangle.create(@pos.x - SIZE / 2.0 , @pos.y - SIZE / 2.0, SIZE, SIZE)
  end

  def update(collision = false)
    self.pos = Vector2Add(pos, velocity)
    bounce_borders
    # bounce_asteroids if collision
  end

  def bounce_borders
    pos.x = FIELD_WIDTH if pos.x > FIELD_WIDTH
    pos.x = 0 if pos.x < 0
    pos.y = 0 if pos.y < 0
    pos.y = FIELD_HEIGHT if pos.y > FIELD_HEIGHT
    # Vector2Rotate(velocity, 90 * DEG2RAD)
  end

  def bounce_asteroids
    self.pos = Vector2Subtract(pos, velocity)
    # Vector2Normalize(Vector2Rotate(velocity, rand(30) * DEG2RAD))
  end

  def damage(i)
    @health -= i
  end

  def facing_direction
    Vector2Rotate(Vector2.create(-1, 0), (rotation - 180) * DEG2RAD)
  end

  def draw
    DrawPolyLinesEx(pos, 3, SIZE, rotation, 5, color)
    DrawText("#{health}", pos.x - 25, pos.y - 35, 20, WHITE)
  end
end
