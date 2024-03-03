class Asteroid
  SIZES = [
    SMALL = 30,
    MEDIUM = 45,
    LARGE = 60,
  ]

  def self.spawn
    x = rand(-SPAWNING_PADDING..SPAWNING_PADDING)
    y = rand(-SPAWNING_PADDING..SPAWNING_PADDING)
    x += SCREEN_WIDTH if x.positive?
    y += SCREEN_HEIGHT if y.positive?
    position = Vector2.create(x, y)

    velocity = Vector2Subtract(SCREEN_CENTER, position)
    velocity = Vector2Scale(Vector2Normalize(velocity), rand(1..3));
    velocity = Vector2Rotate(velocity, rand(-20..20) * DEG2RAD);

    new(velocity: velocity, position: position, size: Asteroid::SIZES.sample)
  end

  attr_accessor :velocity, :position, :size, :rotation, :rotation_speed, :active

  def initialize(velocity:, position:, size:)
    @active = true
    @velocity = velocity
    @position = position
    @rotation = rand(0..360)
    @rotation_speed = rand(-120..120)
    @size = size
  end

  def update
    return unless active

    if position.x < -SPAWNING_PADDING || position.x > SCREEN_WIDTH + SPAWNING_PADDING ||
        position.y < -SPAWNING_PADDING || position.y > SCREEN_HEIGHT + SPAWNING_PADDING
      self.active = false
      return
    end

    self.position = Vector2Add(position, velocity)
    self.rotation += rotation_speed * DEG2RAD
  end

  def draw
    color_by_size = {
      SMALL => GREEN,
      MEDIUM => GOLD,
      LARGE => RED
    }
    DrawPolyLinesEx(position, 5, size, rotation, 5, color_by_size[size])
  end
end
