require 'bundler'
Bundler.require
require_relative 'setup_dll'
require_relative 'asteroid'
require_relative 'player'
require_relative 'projectile'

SCREEN_WIDTH = 1200
SCREEN_HEIGHT = 800
SPAWNING_PADDING = 100
DEG2RAD = Math::PI/180.0
SCREEN_CENTER = Vector2.create(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)
SPAWN_TIMER = 1.4

module Raylib
  class Vector2
    def inspect
      "#<Raylib::Vector2 (#{self.x}, #{self.y})"
    end
  end
end

class Game
  include Raylib

  attr_accessor :player

  def initialize
    @score = 0
    @asteroids = []
    @last_created_at = nil
    @projectiles = []
    @player = Player.new
    @asteroids_to_add = []
    @asteroids_to_remove = []
  end

  def run
    SetTargetFPS(60)
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Asteroids")

      until WindowShouldClose()
        handle_input
        update
        draw
      end
    CloseWindow()
  end

  def handle_input
    if IsKeyPressed(KEY_SPACE)
      @projectiles << Projectile.create(
        origin: Vector2Add(player.facing_direction, player.position),
        position: player.position
      )
    end
    @player.handle_input
  end

  def update
    @player.update

    if @last_created_at.nil? || @last_created_at + SPAWN_TIMER < GetTime()
      @asteroids << Asteroid.spawn
      @last_created_at = GetTime()
    end

    @asteroids += @asteroids_to_add.flatten
    @asteroids_to_add = []

    @asteroids -= @asteroids_to_remove
    @asteroids_to_remove = []

    @asteroids.compact.each(&:update)

    @projectiles.reject! { !_1.active }
    @projectiles.each(&:update)

    @projectiles.each do |p|
      @asteroids.compact.each do |a|
        if CheckCollisionCircles(p.position, 5, a.position, a.size)
          p.active = false
          a.active = false
          @asteroids_to_add << Asteroid.split(a)
          @asteroids_to_remove << a
          @score += 1
        end
      end
    end

    @asteroids.compact.each do |a|
      if CheckCollisionCircles(a.position, a.size, SCREEN_CENTER, 10)
        @player.health -= 10
      end
    end
  end

  def draw
    BeginDrawing()
      ClearBackground(BLACK)
      DrawText("SCORE: #{@score}", 50, 50, 20, WHITE)
      # DrawText("Asteroids: #{@asteroids.count}", 50, 50, 20, WHITE)
      DrawText("HEALTH: #{@player.health}", SCREEN_WIDTH - 170, 50, 20, WHITE)

      @player.draw
      @asteroids.compact.each(&:draw)
      @projectiles.each(&:draw)
    EndDrawing()
  end
end

Game.new.run
