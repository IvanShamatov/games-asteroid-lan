class Player
  attr_accessor :health, :color, :rotation, :id, :position, :score

  def initialize(score:, position:, rotation:, health:, color:, id:)
    @id = id
    @position = position
    @rotation = rotation
    @health = health
    @color = color
    @score = score
  end

  def draw
    DrawPolyLinesEx(position, 3, 30, rotation, 5, color)
    DrawText("#{health}", position.x - 25, position.y - 35, 20, WHITE)
  end
end
