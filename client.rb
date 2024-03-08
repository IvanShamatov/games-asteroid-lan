require 'bundler'
Bundler.require
require 'thread'
require_relative 'setup_dll'

SCREEN_WIDTH = 1280
SCREEN_HEIGHT = 800
DEG2RAD = Math::PI/180.0
SCREEN_CENTER = Vector2.create(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)

class Game
  include Raylib

  attr_accessor :player

  def initialize
    @connection = Redis.new(host: 'redis', port: 6379)
    @client_id = Nanoid.generate(size: 5)
    @message_queue = Queue.new
    run_redis_subscription()
    puts "Connected #{@client_id}"
    publish_message({type: "new_client", id: @client_id})
    @players = []
    @bullets = []
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

      send_disonnect
    CloseWindow()
  end

  def send_disonnect
    publish_message({type: 'disconnect', id: @client_id})
  end

  def handle_input
    inputs_to_send = {
      x: int_key_down(KEY_A) - int_key_down(KEY_D),
      y: int_key_down(KEY_W) - int_key_down(KEY_S),
      shoot: IsKeyPressed(KEY_SPACE) || IsMouseButtonPressed(MOUSE_BUTTON_LEFT),
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
            color: GetColor(array_to_hex(p['color'])),
            score: p['score']
          )
        end

        @bullets = message['bullets'].map do |b|
          Bullet.new(
            position: Vector2.create(b['position'][0], b['position'][1]),
            color: GetColor(array_to_hex(b['color']))
          )
        end
      end
    end
    # @players.each(&:update)
  end

  def array_to_hex(color_array)
    color_array.map { |c| c.to_s(16).rjust(2, '0') }.join.to_i(16)
  end

  def draw
    BeginDrawing()
      ClearBackground(BLACK)
      draw_score
      @players.each(&:draw)
      @bullets.each(&:draw)
    EndDrawing()
  end

  def draw_score
    DrawText("SCORE:", 50, 50, 20, WHITE)
    @players.each_with_index do |p, i|
      DrawText("#{p.id}: #{p.score}", 50, 80 + 30*i, 20, p.color)
    end
  end
end

class Bullet
  attr_accessor :position, :color

  def initialize(position:, color:)
    @position = position
    @color = color
  end

  def draw
    DrawCircleV(position, 5, color)
  end
end


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

Game.new.run
