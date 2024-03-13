require 'bundler'
Bundler.require
require 'thread'
require_relative 'setup_dll'
require_relative 'camera_box'
require_relative 'player'
require_relative 'enemy'
require_relative 'bullet'
require_relative 'asteroid'

FIELD_WIDTH = 3000
FIELD_HEIGHT = 3000
MARGIN = 100
SCREEN_WIDTH = 1280
SCREEN_HEIGHT = 800
DEG2RAD = Math::PI/180.0
SCREEN_CENTER = Vector2.create(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)

class Game
  attr_accessor :player, :camera, :asteroids, :enemies

  def initialize
    @player = Player.new(id: Nanoid.generate(size: 5))
    @camera = Camera2D.new
              .with_target(player.pos.x, player.pos.y)
              .with_offset(SCREEN_WIDTH / 2.0, SCREEN_HEIGHT / 2.0)
              .with_rotation(0.0)
              .with_zoom(1.0)

    @camera_bb = Rectangle.create(SCREEN_WIDTH / 2.0 - 50,  SCREEN_HEIGHT / 2.0 - 50, 100, 100)

    @asteroids = []
    50.times do |i|
      @asteroids << Asteroid.new(rand(FIELD_WIDTH), rand(FIELD_HEIGHT))
    end

    @enemies = []
    10.times do
      @enemies << Enemy.new(id: Nanoid.generate(size: 5), pos: Vector2.create(rand(FIELD_WIDTH), rand(FIELD_HEIGHT)))
    end

    @bullets = []
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

    if shoot
      @bullets << Bullet.new(
        id: player.id,
        direction: player.facing_direction,
        pos: player.pos,
        color: player.color
      )
    end

    collision = false
    @asteroids.each do |a|
      # if CheckCollisionRecs(a.rect, player.rect)
        if CheckCollisionCircles(a.pos, a.size - 10, player.pos, Player::SIZE - 10)
          collision = true
        end
      # end

      @bullets.each do |b|
        b.active = false if CheckCollisionCircles(a.pos, a.size - 10, b.pos, Bullet::SIZE)
      end

      @enemies.each do |e|
        e_collision = false
        # if CheckCollisionRecs(a.rect, e.rect)
        #   if CheckCollisionCircles(a.pos, a.size, e.pos, Enemy::SIZE)
        #     e_collision = true
        #   end
        # end
      end
    end

    player.update(
      x: int_key_down(KEY_A) - int_key_down(KEY_D),
      y: int_key_down(KEY_W) - int_key_down(KEY_S),
      ft: GetFrameTime(),
      collision: collision
    )

    @bullets.reject!{ !_1.active }
    @bullets.each(&:update)

    @enemies.each(&:update)

    # TODO: Align enemy movements and rotation
    camera.target.set(player.camera_box.x, player.camera_box.y)
    camera.offset.y = SCREEN_HEIGHT/2.0
    camera.offset.x = SCREEN_WIDTH/2.0

    if player.camera_box.x < SCREEN_WIDTH/2.0
      camera.offset.x = player.camera_box.x
    end

    if player.camera_box.y < SCREEN_HEIGHT/2.0
      camera.offset.y = player.camera_box.y
    end

    if player.camera_box.x > FIELD_WIDTH - SCREEN_WIDTH/2.0
      camera.offset.x = player.camera_box.x - FIELD_WIDTH + SCREEN_WIDTH
    end

    if player.camera_box.y > FIELD_HEIGHT - SCREEN_HEIGHT/2.0
      camera.offset.y = player.camera_box.y - FIELD_HEIGHT + SCREEN_HEIGHT
    end

    asteroids_to_draw()
    enemies_split()
    bullets_to_draw()
  end

  def bullets_to_draw
    screen_tl = Vector2Subtract(camera.target, camera.offset)
    tl = Vector2SubtractValue(screen_tl, Bullet::SIZE)
    br = Vector2Add(screen_tl, Vector2.create(SCREEN_WIDTH + Bullet::SIZE, SCREEN_HEIGHT + Bullet::SIZE))

    @bullets_to_draw = @bullets.select do |a|
      a.pos.x >= tl.x && a.pos.x <= br.x && a.pos.y >= tl.y && a.pos.y <= br.y
    end
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
        @bullets_to_draw.each(&:draw)
        # puts "Player: #{player.pos.inspect}\nCamera target: #{camera.target.inspect}\nCamera offset: #{camera.offset.inspect}"
        # puts "camera.target.x - camera.offset.x: #{camera.target.x - camera.offset.x}"
        # puts "camera.target.x + camera.offset.x: #{camera.target.x + camera.offset.x}"
        # @enemies_invisible.each do |enemy|
        #   DrawLineV(player.pos, enemy.pos, enemy.color)
        # end
      EndMode2D()
      DrawFPS(50, 50)
      DrawText("Asteroids visible: #{@asteroids_to_draw.count}", 50, 100, 20, Fade(GREEN, 0.5))
      DrawText("Enemies visible: #{@enemies_to_draw.count}", 50, 130, 20, Fade(GREEN, 0.5))
      DrawText("Bullets visible: #{@bullets_to_draw.count}", 50, 160, 20, Fade(GREEN, 0.5))
    EndDrawing()
  end
end

Game.new.run
