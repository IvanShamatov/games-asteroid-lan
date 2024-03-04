class Player
  PLAYER_ROT_SPEED = 4.0
  PLAYER_ACCELERATION = 30
  PLAYER_DECELERATION = 0.2
  MAX_SPEED = 5

  attr_accessor :health, :position, :rotation, :velocity

  def initialize
    @health = 100
    @position = SCREEN_CENTER
    @rotation = 0
    @velocity = Vector2Zero()
  end

  def handle_input
    frametime = GetFrameTime()

    x = int_key_down(KEY_A) - int_key_down(KEY_D)
    self.rotation -= (x * PLAYER_ROT_SPEED)
    # d = Vector2Add(Vector2.create(50, 0), position)
    # @direction = Vector2Rotate(d, rotation * DEG2RAD)
    # self.direction = Vector2Rotate(direction, PLAYER_ROT_SPEED)

    y = int_key_down(KEY_W) - int_key_down(KEY_S)
    if y == 0
      self.velocity = Vector2Lerp(velocity, Vector2Zero(), PLAYER_ACCELERATION * frametime)
    else
      mag = Vector2Length(velocity)
      if mag <= MAX_SPEED
        self.velocity = Vector2Add(velocity, Vector2Scale(facing_direction, PLAYER_ACCELERATION * frametime))
      end
    end
  end

  def int_key_down(key)
    IsKeyDown(key) ? 1 : 0
  end

  def update
    self.position = Vector2Add(position, velocity)
    position.x = 0 if position.x > SCREEN_WIDTH
    position.x = SCREEN_WIDTH if position.x < 0
    position.y = 0 if position.y > SCREEN_HEIGHT
    position.y = SCREEN_HEIGHT if position.y < 0
  end

  def facing_direction
    Vector2Rotate(Vector2.create(-1, 0), (rotation - 180) * DEG2RAD)
  end

  def draw
    DrawPolyLinesEx(position, 3, 30, rotation, 5, WHITE)
    # DrawLineV(position, direction, WHITE)
  end
end
