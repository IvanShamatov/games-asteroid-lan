require 'bundler'
Bundler.require
require_relative 'setup_dll'

SCREEN_WIDTH = 1280
SCREEN_HEIGHT = 800
DEG2RAD = Math::PI/180.0
SCREEN_CENTER = Vector2.create(SCREEN_WIDTH / 2, SCREEN_HEIGHT / 2)


class Player
  PLAYER_ROT_SPEED = 4.0
  PLAYER_ACCELERATION = 30
  PLAYER_DECELERATION = 0.2
  MAX_SPEED = 5

  attr_accessor :health, :position, :rotation, :velocity, :id, :color, :score

  def initialize(id)
    @id = id
    @health = 100
    @position = Vector2.create(rand(SCREEN_WIDTH), rand(SCREEN_HEIGHT))
    @rotation = 0
    @velocity = Vector2Zero()
    @color = [WHITE, GREEN, GOLD, SKYBLUE, RED].sample
    @score = 0
  end

  def update(x = 0, y = 0, frametime = nil)
    self.rotation -= (x * PLAYER_ROT_SPEED)

    if y == 0
      self.velocity = Vector2Lerp(velocity, Vector2Zero(), PLAYER_ACCELERATION * frametime)
    else
      mag = Vector2Length(velocity)

      self.velocity = Vector2Add(velocity, Vector2Scale(facing_direction, PLAYER_ACCELERATION * frametime))
      if mag > MAX_SPEED
        self.velocity = Vector2Scale(velocity, MAX_SPEED / mag)
      end
    end

    self.position = Vector2Add(position, velocity)
    position.x = 0 if position.x > SCREEN_WIDTH
    position.x = SCREEN_WIDTH if position.x < 0
    position.y = 0 if position.y > SCREEN_HEIGHT
    position.y = SCREEN_HEIGHT if position.y < 0
  end

  def damage(i)
    @health -= i
  end

  def facing_direction
    Vector2Rotate(Vector2.create(-1, 0), (rotation - 180) * DEG2RAD)
  end
end


class Bullet
  BULLET_SPEED = 10

  attr_accessor :active, :position, :color, :id

  def initialize(id:, direction:, position:, color:)
    @id = id
    @active = true
    @velocity = Vector2Scale(Vector2Normalize(direction), BULLET_SPEED)
    @position = position
    @color = color
  end

  def update
    @position = Vector2Add(@position, @velocity)
    if @position.x < 0 || @position.x > SCREEN_WIDTH || @position.y < 0 || @position.y > SCREEN_HEIGHT
      @active = false
    end
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

        when "disconnect"
          @players.reject! {_1.id == parsed_message['id']}
        end
      end
    end
  end

  def update_state(m)
    player = @players.find { _1.id == m['id'] }
    player.update(m.dig("inputs", "x"), m.dig("inputs", "y"), m.dig("inputs", "ft"))

    if m.dig("inputs", "shoot")
      @bullets << Bullet.new(
        id: player.id,
        direction: player.facing_direction,
        position: player.position,
        color: player.color
      )
    end

    @bullets.reject!{ !_1.active }
    @bullets.each(&:update)

    @bullets.each do |bullet|
      @players.each do |player|
        next if bullet.id == player.id
        if CheckCollisionCircles(bullet.position, 5, player.position, 30)
          bullet.active = false
          player.damage(1)
          @players.find { _1.id == bullet.id }.score += 1
        end
      end
    end
  end

  def publish_state
    message = {
      players: @players.map do |p|
        {
          id: p.id,
          health: p.health,
          position: [p.position.x, p.position.y],
          rotation: p.rotation,
          color: p.color.values,
          score: p.score
        }
      end,
      bullets: @bullets.map do |b|
        {
          color: b.color.values,
          position: [b.position.x, b.position.y]
        }
      end
    }
    publish_message(message)
  end
end


Server.new.run!
