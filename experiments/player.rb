class Player
  PLAYER_ROT_SPEED = 4.0
  PLAYER_ACCELERATION = 30
  PLAYER_DECELERATION = 0.2
  MAX_SPEED = 10

  attr_reader :id

  attr_accessor :health, :position, :rotation, :velocity, :color, :score

  def initialize(id)
    @id = id
    @health = 100
    @position = SCREEN_CENTER
    @rotation = 0
    @velocity = Vector2Zero()
    @color = [WHITE, GREEN, GOLD, SKYBLUE, RED].sample
    @score = 0
  end

  def update(x: 0, y: 0, ft: nil)
    self.rotation -= (x * PLAYER_ROT_SPEED)

    if y == 0
      self.velocity = Vector2Lerp(velocity, Vector2Zero(), PLAYER_ACCELERATION * ft)
    else
      mag = Vector2Length(velocity)

      self.velocity = Vector2Add(velocity, Vector2Scale(facing_direction, PLAYER_ACCELERATION * ft))
      if mag > MAX_SPEED
        self.velocity = Vector2Scale(velocity, MAX_SPEED / mag)
      end
    end

    self.position = Vector2Add(position, velocity)
    bounce_borders
  end

  def bounce_borders
    position.x = FIELD_WIDTH if position.x > FIELD_WIDTH
    position.x = 0 if position.x < 0
    position.y = 0 if position.y < 0
    position.y = FIELD_HEIGHT if position.y > FIELD_HEIGHT
  end

  def damage(i)
    @health -= i
  end

  def facing_direction
    Vector2Rotate(Vector2.create(-1, 0), (rotation - 180) * DEG2RAD)
  end

  def draw
    DrawPolyLinesEx(position, 3, 30, rotation, 5, color)
    DrawText("#{health}", position.x - 25, position.y - 35, 20, WHITE)
  end
end