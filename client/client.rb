require 'bundler'
Bundler.require
require 'thread'
require_relative 'setup_dll'
require_relative 'player'
require_relative 'bullet'
require_relative 'connection'

SCREEN_WIDTH = 1280
SCREEN_HEIGHT = 800
DEG2RAD = Math::PI/180.0
SCREEN_CENTER = Vector2.create(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)

class Game
  include Raylib

  attr_accessor :player, :conn

  def initialize
    @state = :not_connected #:game
    @conn = Connection.new
    @message_queue = Queue.new
    @player = Player.create(id: Nanoid.generate(size: 5))
    # run_redis_subscription()
    # publish_message({type: "new_client", id: @client_id})
    @enemies = {}
    @bullets = {}

    @server_input = FFI::MemoryPointer.new(:char, 64)
    @server_input.write_string("Server IP:PORT")
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

  def run

    @exit_window = false
    @show_are_you_sure = false
    SetTargetFPS(60)
    InitWindow(SCREEN_WIDTH, SCREEN_HEIGHT, "Asteroids Lan")
    GuiLoadStyle('style_dark.rgs')

    until @exit_window
      @exit_window = WindowShouldClose()
      @show_are_you_sure = !@show_are_you_sure if IsKeyPressed(KEY_ESCAPE)

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
      shoot: IsKeyPressed(KEY_SPACE) || IsMouseButtonPressed(MOUSE_BUTTON_LEFT),
      ft: GetFrameTime()
    }
    # publish({drawype: 'tick', id: @client_id, inputs: inputs_to_send})
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
      if @state == :connecting
        draw_input
      elsif @state == :connected
        draw_score
        @enemies.each(&:draw)
        @bullets.each(&:draw)
      end
      @player.draw
    EndDrawing()
  end

  def draw_input
    # textBoxEditMode = false
    result = GuiTextBox(Rectangle.create(50, 200, 100,55), @server_input, @server_input.size, true)
    # textBoxEditMode = !textBoxEditMode if result != 0
  end

  def draw_score
    DrawText("SCORE:", 50, 50, 20, WHITE)
    @players.each_with_index do |p, i|
      DrawText("#{p.id}: #{p.score}", 50, 80 + 30*i, 20, p.color)
    end
  end
end

Game.new.run
