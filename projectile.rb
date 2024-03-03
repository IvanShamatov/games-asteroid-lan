class Projectile

  attr_accessor :velocity, :position, :active

  def self.create(origin:, position:)
    velocity = Vector2Subtract(origin, position)
    velocity = Vector2Scale(Vector2Normalize(velocity), 5)

    new(velocity: velocity, position: position)
  end

  def initialize(velocity:, position:)
    @active = true
    @velocity = velocity
    @position = position
  end

  def update
    if position.x < 0 || position.x > SCREEN_WIDTH  || position.y < 0 || position.y > SCREEN_HEIGHT
      self.active = false
      return
    end

    self.position = Vector2Add(position, velocity)
  end

  def draw
    DrawCircleV(position, 5, SKYBLUE)
  end
end
