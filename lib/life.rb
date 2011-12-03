class Life
end

class World
  attr_accessor :map
  
  def initialize(width, height)
    @map = Array.new(height) {|i| Array.new(width) } 
  end
  
  def cell_size
    self.to_s.count("O")
  end
  
  def to_s
    @map.map { |x| x.map { |y| y.nil? ? 'X' : 'O' }.join }.join("\n")
  end
end

class Cell
  def initialize
    @status = :alive
  end
  
  def alive?
    @status == :alive
  end
end