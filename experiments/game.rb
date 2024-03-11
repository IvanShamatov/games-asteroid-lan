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
  MAX_SIZE = 80
  MIN_SIZE = 30

  def initialize(x, y)
    @pos = Vector2.create(x, y)
    @color = [GOLD, YELLOW, RED, WHITE].sample
    @size = rand(MIN_SIZE..MAX_SIZE)
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
              .with_target(player.pos.x, player.pos.y)
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

    camera.target.set(player.pos.x, player.pos.y)
    camera.offset.y = SCREEN_HEIGHT/2.0
    camera.offset.x = SCREEN_WIDTH/2.0

    if player.pos.x < SCREEN_WIDTH/2.0
      camera.offset.x = player.pos.x
    end

    if player.pos.y < SCREEN_HEIGHT/2.0
      camera.offset.y = player.pos.y
    end

    if player.pos.x > FIELD_WIDTH - SCREEN_WIDTH/2.0
      camera.offset.x = player.pos.x - FIELD_WIDTH + SCREEN_WIDTH
    end

    if player.pos.y > FIELD_HEIGHT - SCREEN_HEIGHT/2.0
      camera.offset.y = player.pos.y - FIELD_HEIGHT + SCREEN_HEIGHT
    end

    asteroids_to_draw()
    enemies_split()
  end

  def asteroids_to_draw
    screen_tl = Vector2Subtract(camera.target, camera.offset)
    tl = Vector2SubtractValue(screen_tl, Asteroid::MAX_SIZE)
    br = Vector2Add(screen_tl, Vector2.create(SCREEN_WIDTH + Asteroid::MAX_SIZE, SCREEN_HEIGHT + Asteroid::MAX_SIZE))

    @asteroids_to_draw = @asteroids.select do |a|
      a.pos.x >= tl.x && a.pos.x <= br.x && a.pos.y >= tl.y && a.pos.y <= br.y
    end
  end

  def enemies_split
    screen_tl = Vector2Subtract(camera.target, camera.offset)
    tl = Vector2SubtractValue(screen_tl, Enemy::SIZE)
    br = Vector2Add(screen_tl, Vector2.create(SCREEN_WIDTH + Enemy::SIZE, SCREEN_HEIGHT + Enemy::SIZE))

    @enemies_to_draw = @enemies.select do |a|
      a.pos.x >= tl.x && a.pos.x <= br.x && a.pos.y >= tl.y && a.pos.y <= br.y
    end
    @enemies_invisible = @enemies - @enemies_to_draw
  end

  def draw
    BeginDrawing()
      ClearBackground(BLACK)
      BeginMode2D(camera)
        DrawRectangleLines(0, 0, FIELD_WIDTH, FIELD_HEIGHT, Fade(GOLD, 0.5))
        player.draw
        @asteroids_to_draw.each(&:draw)
        @enemies_to_draw.each(&:draw)
        # puts "Player: #{player.pos.inspect}\nCamera target: #{camera.target.inspect}\nCamera offset: #{camera.offset.inspect}"
        # puts "camera.target.x - camera.offset.x: #{camera.target.x - camera.offset.x}"
        # puts "camera.target.x + camera.offset.x: #{camera.target.x + camera.offset.x}"
        @enemies_invisible.each do |enemy|
          DrawLineV(player.pos, enemy.pos, enemy.color)
        end
      EndMode2D()
      DrawFPS(50, 50)
      DrawText("Asteroids visible: #{@asteroids_to_draw.count}", 50, 100, 20, Fade(GREEN, 0.5))
      DrawText("Asteroids visible: #{@enemies_to_draw.count}", 50, 130, 20, Fade(GREEN, 0.5))
    EndDrawing()
  end
end

Game.new.run
