require_relative 'setup_dll'

class Player
  attr_accessor :position, :speed, :canJump

  def initialize()
    @position = Vector2.create(400, 280)
    @speed = 0.0
    @canJump = false
  end
end

class EnvElement
  attr_accessor :rect, :blocking, :color

  def initialize(rect, blocking, color)
    @rect = rect
    @blocking = blocking
    @color = color
  end
end

if __FILE__ == $PROGRAM_NAME
  GRAVITY = 400
  PLAYER_JUMP_SPD = 350.0
  PLAYER_HOR_SPD = 200.0

  screenWidth = 800
  screenHeight = 450
  InitWindow(screenWidth, screenHeight, "Yet Another Ruby-raylib bindings - automation events")

  player = Player.new

  envElements = [
    EnvElement.new(Rectangle.create(0, 0, 1000, 400), 0, LIGHTGRAY),
    EnvElement.new(Rectangle.create(0, 400, 1000, 200), 1, GRAY),
    EnvElement.new(Rectangle.create(300, 200, 400, 10), 1, GRAY),
    EnvElement.new(Rectangle.create(250, 300, 100, 10), 1, GRAY),
    EnvElement.new(Rectangle.create(650, 300, 100, 10), 1, GRAY),
  ]

  camera = Camera2D.new
             .with_target(player.position.x, player.position.y)
             .with_offset(screenWidth / 2.0, screenHeight / 2.0)
             .with_rotation(0.0)
             .with_zoom(1.0)


  SetTargetFPS(60)

  until WindowShouldClose()

    deltaTime = 0.015 # GetFrameTime()


    # Update player
    player.position.x -= PLAYER_HOR_SPD * deltaTime if IsKeyDown(KEY_LEFT)
    player.position.x += PLAYER_HOR_SPD * deltaTime if IsKeyDown(KEY_RIGHT)
    if IsKeyDown(KEY_SPACE) && player.canJump
      player.speed = -PLAYER_JUMP_SPD
      player.canJump = false
    end

    hitObstacle = false
    envElements.each do |element|
      if element.blocking &&
         (element.rect.x <= player.position.x) && (element.rect.x + element.rect.width >= player.position.x) &&
         (element.rect.y >= player.position.y) && (element.rect.y <= player.position.y + player.speed * deltaTime)
        hitObstacle = true
        player.speed = 0.0
        player.position.y = element.rect.y
      end
    end

    unless hitObstacle
      player.position.y += player.speed * deltaTime
      player.speed += GRAVITY * deltaTime
      player.canJump = false
    else
      player.canJump = true
    end

    # Camera target follows player
    camera.target.set(player.position.x, player.position.y)
    camera.offset.x = screenWidth/2.0
    camera.offset.y = screenHeight/2.0

    minX = 1000
    minY = 1000
    maxX = -1000
    maxY = -1000
    envElements.each do |element|
      minX = [element.rect.x, minX].min
      maxX = [element.rect.x + element.rect.width, maxX].max
      minY = [element.rect.y, minY].min
      maxY = [element.rect.y + element.rect.height, maxY].max
    end

    max = GetWorldToScreen2D(Vector2.create(maxX, maxY), camera)
    min = GetWorldToScreen2D(Vector2.create(minX, minY), camera)

    camera.offset.x = screenWidth - (max.x - screenWidth/2) if max.x < screenWidth
    camera.offset.y = screenHeight - (max.y - screenHeight/2) if max.y < screenHeight
    camera.offset.x = screenWidth/2 - min.x if min.x > 0
    camera.offset.y = screenHeight/2 - min.y if min.y > 0

    BeginDrawing()
      ClearBackground(LIGHTGRAY)

      BeginMode2D(camera)
        envElements.each do |element|
          DrawRectangleRec(element.rect, element.color)
        end
        DrawRectangleRec(Rectangle.create(player.position.x - 20, player.position.y - 40, 40, 40), RED)
      EndMode2D()

      DrawRectangle(10, 10, 290, 145, Fade(SKYBLUE, 0.5))
      DrawRectangleLines(10, 10, 290, 145, Fade(BLUE, 0.8))

    EndDrawing()
  end

  CloseWindow()
end
