class Player
  PLAYER_ROT_SPEED = 4.0
  PLAYER_ACCELERATION = 30
  PLAYER_DECELERATION = 5
  MAX_SPEED = 10
  SIZE = 30
  CAMERA_BOX_SIZE = 4 * SIZE

  attr_reader :id

  attr_accessor :health, :pos, :rotation, :velocity, :color, :score, :rect, :camera_box

  def initialize(id)
    @id = id
    @health = 100
    @pos = SCREEN_CENTER
    @rotation = 0
    @velocity = Vector2Zero()
    @color = [WHITE, GREEN, GOLD, SKYBLUE, RED].sample
    @score = 0
    @rect = Rectangle.create(@pos.x - SIZE , @pos.y - SIZE, 2 * SIZE, 2 * SIZE)
    @camera_box = CameraBox.new(Vector2.create(@pos.x, @pos.y), CAMERA_BOX_SIZE, CAMERA_BOX_SIZE)
  end

  def update(x: 0, y: 0, ft: nil, collision: false)
    self.rotation -= (x * PLAYER_ROT_SPEED)

    if y == 0
      self.velocity = Vector2Lerp(velocity, Vector2Zero(), PLAYER_DECELERATION * ft)
    else
      mag = Vector2Length(velocity)

      self.velocity = Vector2Add(velocity, Vector2Scale(facing_direction, PLAYER_ACCELERATION * ft))
      if mag > MAX_SPEED
        self.velocity = Vector2Scale(velocity, MAX_SPEED / mag)
      end
    end

    if collision
      self.pos = Vector2Subtract(pos, Vector2Scale(velocity, 5))
      self.velocity = Vector2Zero()
    else
      self.pos = Vector2Add(pos, velocity)
    end
    rect.x, rect.y = pos.x - SIZE, pos.y - SIZE
    bounce_borders
    move_camera_box
  end

  def bounce_borders
    pos.x = FIELD_WIDTH if pos.x > FIELD_WIDTH
    pos.x = 0 if pos.x < 0
    pos.y = 0 if pos.y < 0
    pos.y = FIELD_HEIGHT if pos.y > FIELD_HEIGHT
  end

  def move_camera_box
    camera_box.l = pos.x if pos.x < camera_box.l
    camera_box.r = pos.x if pos.x > camera_box.r
    camera_box.t = pos.y if pos.y < camera_box.t
    camera_box.b = pos.y if pos.y > camera_box.b
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
    DrawRectangleLinesEx(camera_box.rect, 3, Fade(color, 0.5))
  end
end
