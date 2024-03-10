class Player
  PLAYER_ROT_SPEED = 4.0
  PLAYER_ACCELERATION = 30
  PLAYER_DECELERATION = 0.2
  MAX_SPEED = 5

  attr_accessor :health, :color, :rotation, :id, :position, :score

  def self.create(id:)
    new(
      score: 0,
      position: Vector2.create(
        GetScreenWidth()/2.0,
        GetScreenHeight()/2.0
      ),
      rotation: 0,
      health: HEALTH,
      color:

    )
  end

  def initialize(id:, score:, position:, rotation:, health: HEALTH, color:, velocity:)
    @id = id
    @position = position
    @rotation = rotation
    @health = HEALTH
    @color = color
    @score = score
    @velocity = velocity
  end

  def draw
    DrawPolyLinesEx(position, 3, 30, rotation, 5, color)
    DrawText("#{health}", position.x - 25, position.y - 35, 20, WHITE)
  end

  def update(x = 0, y = 0, frametime = nil)
    self.rotation -= (x * PLAYER_ROT_SPEED)

    if y == 0
      self.velocity = Vector2Lerp(velocity, Vector2Zero(), PLAYER_ACCELERATION * frametime)
    else
      mag = Vector2Length(velocity)

      self.velocity = Vector2Add(velocity, Vector2Scale(facing_direction, PLAYER_ACCELERATION * frametime))
      if mag > MAX_SPEED
        self.velocity = Vector2Scale(velocity, MAX_SPEED / mag)
      end
    end

    self.position = Vector2Add(position, velocity)
    position.x = 0 if position.x > SCREEN_WIDTH
    position.x = SCREEN_WIDTH if position.x < 0
    position.y = 0 if position.y > SCREEN_HEIGHT
    position.y = SCREEN_HEIGHT if position.y < 0
  end

  def facing_direction
    Vector2Rotate(Vector2.create(-1, 0), (rotation - 180) * DEG2RAD)
  end
end
