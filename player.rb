class Player
  attr_accessor :health, :position, :rotation

  def initialize
    @health = 100
    @position = SCREEN_CENTER
    @rotation = 0
    @orientation = SCREEN_CENTER
  end

  def handle_input

  end

  def update
  end

  def draw
    DrawPolyLinesEx(position, 3, 30, rotation, 5, WHITE)
  end
end
