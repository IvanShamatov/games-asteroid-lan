require 'bundler'
Bundler.require
require 'thread'
require_relative 'setup_dll'

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
DEG2RAD = Math::PI/180.0
SCREEN_CENTER = Vector2.create(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)

class Game
  include Raylib

  attr_accessor :player

  def initialize
    @state = State.new
    @connection = Redis.new(host: 'localhost', port: 6379)
    @client_id = Nanoid.generate(size: 5)
    @message_queue = Queue.new
    run_redis_subscription()
    puts 'Connected #{@client_id}'
    publish_message({type: "new_client", id: @client_id})
    @players = []
  end


# Function to initialize and run the Redis subscription
  def run_redis_subscription
    Thread.new do
      @connection.subscribe("game_#{@client_id}_channel") do |on|
        on.message do |channel, message|
          m = JSON.parse(message)
          @message_queue << m
        end
      end
    end
  end

  def publish_message(message)
    json_message = message.to_json
    @connection.publish('input_handle_channel', json_message)
  end

  def run
    SetTargetFPS(60)
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Asteroids Lan")
      until WindowShouldClose()
        handle_input
        update
        draw
      end
    CloseWindow()
  end

  def handle_input
    inputs_to_send = {
      x: int_key_down(KEY_A) - int_key_down(KEY_D),
      y: int_key_down(KEY_W) - int_key_down(KEY_S),
      shoot: IsKeyPressed(KEY_SPACE),
      ft: GetFrameTime()
    }
    publish_message({type: 'tick', id: @client_id, inputs: inputs_to_send})
  end

  def int_key_down(key)
    IsKeyDown(key) ? 1 : 0
  end

  def update
    unless @message_queue.empty?
      until @message_queue.empty?
        message = @message_queue.pop
        # puts message
        @players = message['players'].map do |p|
          Player.new(
            id: p['id'],
            health: p['health'],
            position: Vector2.create(p['position'][0], p['position'][1]),
            rotation: p['rotation'],
            color: GetColor(array_to_hex(p['color']))
          )
        end
      end
    end
    # @players.each(&:update)


    # @bullets.each do |p|
    #   @players.each do |player|
    #     if CheckCollisionCircles(p.position, 5, player.position, 30)
    #       p.active = false
    #       a.active = false
    #     end
    #   end
    # end
  end

  def array_to_hex(color_array)
    color_array.map { |c| c.to_s(16).rjust(2, '0') }.join.to_i(16)
  end

  def draw
    BeginDrawing()
      ClearBackground(BLACK)
      @players.each(&:draw)
    EndDrawing()
  end
end

class State
  def draw

  end
end


class Bullet

  attr_accessor :velocity, :position, :active

  def self.create(origin:, position:, player:)
    velocity = Vector2Subtract(origin, position)
    velocity = Vector2Scale(Vector2Normalize(velocity), 10)

    new(velocity: velocity, position: position, player: player)
  end

  def initialize(velocity:, position:,player:)
    @active = true
    @velocity = velocity
    @position = position
    @player = player
  end

  def update
    if position.x < 0 || position.x > SCREEN_WIDTH  || position.y < 0 || position.y > SCREEN_HEIGHT
      self.active = false
      return
    end

    self.position = Vector2Add(position, velocity)
  end

  def draw
    DrawCircleV(position, 5, player.color)
  end
end


class Player
  attr_accessor :health, :color, :rotation, :health, :id, :position

  def handle_input
    frametime = GetFrameTime()

    x = int_key_down(KEY_A) - int_key_down(KEY_D)
    y = int_key_down(KEY_W) - int_key_down(KEY_S)
  end

  def int_key_down(key)
    IsKeyDown(key) ? 1 : 0
  end

  def initialize(position:, rotation:, health:, color:, id: )
    @id = id
    @position = position
    @rotation = rotation
    @health = health
    @color = color
  end

  def draw
    DrawPolyLinesEx(position, 3, 30, rotation, 5, color)
    DrawText("#{health}", position.x - 25, position.y - 35, 10, WHITE)
  end
end

Game.new.run
