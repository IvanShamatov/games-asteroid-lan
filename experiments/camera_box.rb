class CameraBox
  attr_accessor :x, :y
  attr_reader :w, :h, :center, :w2, :h2, :rect

  def initialize(center, width, height)
    @center = center
    @x, @y, @w, @h = center.x, center.y, width, height
    @w2 = @w / 2.0
    @h2 = @h / 2.0
  end

  def ltv
    Vector2.create(@x - @w / 2.0, @y - @h / 2.0)
  end

  def rtv
    Vector2.create(@x - @w / 2.0, @y + @h / 2.0)
  end

  def lbv
    Vector2.create(@x + @w / 2.0, @y - @h / 2.0)
  end

  def rbv
    Vector2.create(@x + @w / 2.0, @y + @h / 2.0)
  end

  def rect
    Rectangle.create(@x - @w2, @y - @h2, @w, @h)
  end

  def l
    @x - @w2
  end

  def l=(l)
    @x = l + @w2
  end

  def r
    @x + @w2
  end

  def r=(r)
    @x = r - @w2
  end

  def t
    @y - @h2
  end

  def t=(t)
    @y = t + @h2
  end

  def b
    @y + @h2
  end

  def b=(b)
    @y = b - @h2
  end
end
