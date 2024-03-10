require 'bundler'
Bundler.require
require 'thread'
require_relative 'setup_dll'
require_relative 'player'
require_relative 'enemy'


FIELD_WIDTH = 3000
FIELD_HEIGHT = 3000
MARGIN = 100
SCREEN_WIDTH = 1280
SCREEN_HEIGHT = 800
DEG2RAD = Math::PI/180.0
SCREEN_CENTER = Vector2.create(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)

class Asteroid
  attr_reader :pos

  def initialize(x, y)
    @pos = Vector2.create(x, y)
    @color = [GOLD, YELLOW, RED, WHITE].sample
    @size = (rand(5) + 3) * 10
  end

  def draw
    DrawPolyLinesEx(pos, 5, @size, 0, 5, Fade(@color, 0.5))
  end
end

class Game
  attr_accessor :player, :camera, :asteroids, :enemies

  def initialize
    @player = Player.new(id: Nanoid.generate(size: 5))
    @camera = Camera2D.new
              .with_target(player.position.x, player.position.y)
              .with_offset(SCREEN_WIDTH / 2.0, SCREEN_HEIGHT / 2.0)
              .with_rotation(0.0)
              .with_zoom(1.0)

    @asteroids = []
    50.times do |i|
      @asteroids << Asteroid.new(rand(FIELD_WIDTH), rand(FIELD_HEIGHT))
    end

    @enemies = []
    10.times do
      @enemies << Enemy.new(id: Nanoid.generate(size: 5), pos: Vector2.create(rand(FIELD_WIDTH), rand(FIELD_HEIGHT)))
    end
  end

  def run
    SetTargetFPS(60)
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Asteroids Lan")

    until WindowShouldClose()
      update
      draw
    end

    CloseWindow()
  end


  def int_key_down(key)
    IsKeyDown(key) ? 1 : 0
  end

  def update
    shoot =  IsKeyPressed(KEY_SPACE) || IsMouseButtonPressed(MOUSE_BUTTON_LEFT)

    player.update(
      x: int_key_down(KEY_A) - int_key_down(KEY_D),
      y: int_key_down(KEY_W) - int_key_down(KEY_S),
      ft: GetFrameTime()
    )

    camera.target.set(player.position.x, player.position.y)
    camera.offset.y = SCREEN_HEIGHT/2.0
    camera.offset.x = SCREEN_WIDTH/2.0

    if player.position.x < SCREEN_WIDTH/2.0
      camera.offset.x = player.position.x
    end

    if player.position.y < SCREEN_HEIGHT/2.0
      camera.offset.y = player.position.y
    end

    if player.position.x > FIELD_WIDTH - SCREEN_WIDTH/2.0
      camera.offset.x = player.position.x - FIELD_WIDTH + SCREEN_WIDTH
    end

    if player.position.y > FIELD_HEIGHT - SCREEN_HEIGHT/2.0
      camera.offset.y = player.position.y - FIELD_HEIGHT + SCREEN_HEIGHT
    end

    # else
    #   camera.offset.x = SCREEN_WIDTH - (max.x - SCREEN_WIDTH/2) if max.x < SCREEN_WIDTH
    # camera.offset.y = SCREEN_HEIGHT - (max.y - SCREEN_HEIGHT/2) if max.y < SCREEN_HEIGHT
    # camera.offset.x = SCREEN_WIDTH/2 - min.x if min.x > 0
    # camera.offset.y = SCREEN_HEIGHT/2 - min.y if min.y > 0
  end

  def draw
    BeginDrawing()
      ClearBackground(BLACK)
      BeginMode2D(camera)
        DrawRectangleLines(0, 0, FIELD_WIDTH, FIELD_HEIGHT, RED)
        player.draw
        asteroids.each(&:draw)
        enemies.each(&:draw)

        # puts GetScreenToWorld2D(player.position, camera).inspect
      EndMode2D()
    EndDrawing()
  end
end

Game.new.run
