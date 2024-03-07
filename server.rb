require 'bundler'
Bundler.require
require_relative 'setup_dll'

SCREEN_WIDTH = 800
SCREEN_HEIGHT = 600
DEG2RAD = Math::PI/180.0
SCREEN_CENTER = Vector2.create(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)


class Player
  PLAYER_ROT_SPEED = 4.0
  PLAYER_ACCELERATION = 30
  PLAYER_DECELERATION = 0.2
  MAX_SPEED = 5

  attr_accessor :health, :position, :rotation, :velocity, :id, :color

  def initialize(id)
    @id = id
    @health = 100
    @position = Vector2.create(rand(SCREEN_WIDTH), rand(SCREEN_HEIGHT))
    @rotation = 0
    @velocity = Vector2Zero()
    @color = [WHITE, GREEN, GOLD, SKYBLUE, RED].sample
  end

  def update(x = 0, y = 0, frametime = nil)
    self.rotation -= (x * PLAYER_ROT_SPEED)

    if y == 0
      self.velocity = Vector2Lerp(velocity, Vector2Zero(), PLAYER_ACCELERATION * frametime)
    else
      mag = Vector2Length(velocity)
      if mag <= MAX_SPEED
        self.velocity = Vector2Add(velocity, Vector2Scale(facing_direction, PLAYER_ACCELERATION * frametime))
      end
    end

    self.position = Vector2Add(position, velocity)
    position.x = 0 if position.x > SCREEN_WIDTH
    position.x = SCREEN_WIDTH if position.x < 0
    position.y = 0 if position.y > SCREEN_HEIGHT
    position.y = SCREEN_HEIGHT if position.y < 0
  end

  def facing_direction
    Vector2Rotate(Vector2.create(-1, 0), (rotation - 180) * DEG2RAD)
  end
end


class Bullet
  def handle_input
      @bullets << Bullet.create(
        origin: Vector2Add(player.facing_direction, player.position),
        position: player.position
      )
  end
end

class Server
  def initialize
    @connection = Redis.new(host: 'localhost', port: 6379)
    puts 'Connected'
    @players = []
    @bullets = []
    @chans = []
  end

  def publish_message(message)
    json_message = message.to_json
    @chans.each do |ch|
      @connection.publish(ch, json_message)
    end
  end

  def run!
    @connection.subscribe('input_handle_channel') do |on|
      on.message do |channel, message|
        parsed_message = JSON.parse(message)

        case parsed_message["type"]
        when "new_client"
          @players << Player.new(parsed_message["id"])
          @chans << "game_#{parsed_message["id"]}_channel"

        when "tick"
          # puts parsed_message
          update_state(parsed_message)
          publish_state
        end
      end
    end
  end

  def update_state(m)
    p = @players.find { _1.id == m['id'] }
    # binding.pry
    p.update(m.dig("inputs", "x"), m.dig("inputs", "y"), m.dig("inputs", "ft"))

    # "id"=>"mrRnp", "inputs"=>{"x"=>0, "y"=>0, "shoot"=>false, "ft"=>0.01666695810854435}
  end

  def publish_state
    message = {
      players: @players.map do |p|
        {
          id: p.id,
          health: p.health,
          position: [p.position.x, p.position.y],
          rotation: p.rotation,
          color: p.color.values
        }
      end
    }
    # puts message
    publish_message(message)
  end
end


Server.new.run!
