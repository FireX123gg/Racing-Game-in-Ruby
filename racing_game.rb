require 'gosu'

class RaceGame < Gosu::Window
  WIDTH = 800
  HEIGHT = 600

  def initialize
    super(WIDTH, HEIGHT, fullscreen: false)
    self.caption = "Ruby Racing Game"

    @player = Player.new(WIDTH / 2, HEIGHT - 50)
    @obstacles = []
    @score = 0
    @font = Gosu::Font.new(30)
    @background_color = Gosu::Color::WHITE
    @obstacle_speed = 3
    @obstacle_spawn_interval = 60
    @obstacle_spawn_timer = 0
  end

  def update
    close if Gosu.button_down?(Gosu::KB_ESCAPE)

    @player.move_left if Gosu.button_down?(Gosu::KB_LEFT)
    @player.move_right if Gosu.button_down?(Gosu::KB_RIGHT)

    @player.update
    update_obstacles
    check_collision
    update_score
  end

  def draw
    draw_background
    @player.draw
    @obstacles.each(&:draw)
    draw_score
  end

  private

  def draw_background
    draw_quad(0, 0, @background_color, WIDTH, 0, @background_color, WIDTH, HEIGHT, @background_color, 0, HEIGHT, @background_color)
  end

  def draw_score
    @font.draw("Score: #{@score}", 10, 10, 0, 1, 1, Gosu::Color::BLACK)
  end

  def update_obstacles
    @obstacles.each(&:update)
    @obstacles.reject!(&:off_screen?)

    @obstacle_spawn_timer += 1
    spawn_obstacle if @obstacle_spawn_timer == @obstacle_spawn_interval
  end

  def spawn_obstacle
    @obstacles.push(Obstacle.new(rand(WIDTH), 0, @obstacle_speed))
    @obstacle_spawn_timer = 0
  end

  def check_collision
    @obstacles.each do |obstacle|
      if Gosu.distance(@player.x, @player.y, obstacle.x, obstacle.y) < 50
        reset_game
      end
    end
  end

  def update_score
    @score += 1
  end

  def reset_game
    @obstacles.clear
    @score = 0
    @player.reset(WIDTH / 2, HEIGHT - 50)
  end
end

class Player
  attr_reader :x, :y

  def initialize(x, y)
    @x = x
    @y = y
    @speed = 5
  end

  def move_left
    @x -= @speed if @x - @speed > 0
  end

  def move_right
    @x += @speed if @x + @speed < RaceGame::WIDTH
  end

  def update
    # Additional player updates can be added here
  end

  def draw
    Gosu.draw_rect(@x - 25, @y - 25, 50, 50, Gosu::Color::GREEN)
  end

  def reset(x, y)
    @x = x
    @y = y
  end
end

class Obstacle
  attr_reader :x, :y

  def initialize(x, y, speed)
    @x = x
    @y = y
    @speed = speed
  end

  def update
    @y += @speed
  end

  def draw
    Gosu.draw_rect(@x - 25, @y - 25, 50, 50, Gosu::Color::RED)
  end

  def off_screen?
    @y > RaceGame::HEIGHT
  end
end

RaceGame.new.show
