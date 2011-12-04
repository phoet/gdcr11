#!/usr/bin/env ruby
require 'rspec'

class Generation
  attr_accessor :board

  def initialize
    @board = Board.new(20)
    @board.seed
  end

  def next
    gen = Board.new(@board.size)
    gen.cells.each_with_index do |row, i|
      row.each_with_index do |cell, j|
        num = @board.full_neighbours(*cell.coordinates)
        status = @board.cell_by_coordinates(*cell.coordinates).status
        cell.apply_rules(num, status)
      end
    end
    @board = gen
    self
  end

  def to_s(type=:html)
    type == :html ? "<p>#{@board.to_s('<br>')}</p>" : "#{@board}"
  end
end

class Board
  attr_reader :cells, :size

  def initialize(size=10)
    @size = size
    @cells = size.times.map do |i|
      size.times.map do |j|
        Cell.new(i, j)
      end
    end
  end

  def full_neighbours(x, y)
    range_x = (x-1 < 0 ? 0 : x-1)..(x+1 >= @size ? @size-1 : x+1)
    range_y = (y-1 < 0 ? 0 : y-1)..(y+1 >= @size ? @size-1 : y+1)
    @cells[range_x].map do |row|
      row[range_y].reject {|cell| cell.status == :empty || cell.coordinates == [x, y]}
    end.flatten.count
  end

  def cell_by_coordinates(x, y)
    @cells[x][y]
  end

  def seed
    @cells.each do |row|
      @size.times { row[rand(@size)].status = :full }
    end
  end

  def empty_cells
    @cells.map(){|row| row.reject(){|cell| cell.status != :empty } }.flatten
  end

  def to_s(breaker="\n")
    @cells.map { |row| row.map(&:to_s).join }.join(breaker)
  end
end

class Cell
  attr_accessor :x, :y, :status

  def initialize(x, y)
    @x = x
    @y = y
    @status = :empty
  end

  def coordinates
    [@x, @y]
  end

  def apply_rules(neighbours, status)
    if status == :full
      self.status = neighbours < 2 || neighbours > 3 ? :empty : :full
    else
      self.status = :full if neighbours == 3
    end
  end

  def to_s
    @status == :empty ? 'X' : 'O'
  end
end

describe Board do

  context "neighbours" do
    let(:board) { Board.new }
    let(:board_1) { Board.new.tap {|it| it.cells[1][0].status = :full} }
    let(:board_2) { Board.new.tap {|it| it.cells[1][0].status = :full; it.cells[0][1].status = :full} }
    let(:board_3) { Board.new.tap {|it| it.cells[1][0].status = :full; it.cells[1][1].status = :full; it.cells[0][1].status = :full} }
    let(:board_4) { Board.new.tap {|it| it.cells[1][0].status = :full; it.cells[1][1].status = :full; it.cells[0][1].status = :full; it.cells[0][2].status = :full} }
    let(:board_5) { Board.new.tap {|it| it.cells[1][0].status = :full; it.cells[1][1].status = :full; it.cells[1][2].status = :full} }

    it "should find full neighbours" do
      board.full_neighbours(0, 0).should eql(0)
      board_1.full_neighbours(0, 0).should eql(1)
      board_2.full_neighbours(0, 0).should eql(2)
      board_3.full_neighbours(0, 1).should eql(2)
      board_3.full_neighbours(0, 0).should eql(3)
      board_4.full_neighbours(0, 0).should eql(3)
      board_5.full_neighbours(0, 0).should eql(2)
      board_5.full_neighbours(0, 1).should eql(3)
      board_5.full_neighbours(0, 2).should eql(2)
    end
  end

  context "rules" do
    let(:cell) { Cell.new(0, 0) }

    it "Any live cell with fewer than two live neighbours dies, as if caused by under-population." do
      cell.apply_rules(0, :full)
      cell.status.should eql(:empty)
      cell.apply_rules(1, :full)
      cell.status.should eql(:empty)
    end

    it "Any live cell with two or three live neighbours lives on to the next generation." do
      cell.apply_rules(2, :full)
      cell.status.should eql(:full)
      cell.apply_rules(3, :full)
      cell.status.should eql(:full)
    end

    it "Any live cell with more than three live neighbours dies, as if by overcrowding." do
      cell.apply_rules(4, :full)
      cell.status.should eql(:empty)
    end

    it "Any dead cell with exactly three live neighbours becomes a live cell, as if by reproduction." do
      cell.apply_rules(3, :empty)
      cell.status.should eql(:full)
    end
  end

  context "generation" do
    let(:generation) { Generation.new }
    let(:flipper) { Board.new(3).tap {|it| it.cells[1][0].status = :full; it.cells[1][1].status = :full; it.cells[1][2].status = :full} }

    it "should create a generation" do
      generation.should_not be_nil
    end

    it "should have a flipper" do
      generation.board = flipper
      generation.board.to_s.should eql(
        "XXX
OOO
XXX"
      )
      generation.next.board.to_s.should eql(
        "XOX
XOX
XOX"
      )
    end

  end

  context "board" do
    let(:board) { Board.new }

    it "should create a board" do
      board.should_not be_nil
    end

    it "should have cells" do
      board.cells.should have(10).elements
      board.cells.first.should have(10).elements
    end

    it "should find empty cells" do
      board.empty_cells.size.should eql(100)
    end

    it "should seed a board" do
      board.seed
      board.empty_cells.size.should_not eql(100)
    end

    it "should have a string representation" do
      board.to_s.should eql(
        "XXXXXXXXXX
XXXXXXXXXX
XXXXXXXXXX
XXXXXXXXXX
XXXXXXXXXX
XXXXXXXXXX
XXXXXXXXXX
XXXXXXXXXX
XXXXXXXXXX
XXXXXXXXXX"
      )
    end
  end

  context "cell" do
    let(:cell) { Cell.new(0, 0) }

    it "should create a cell" do
      cell.should_not be_nil
    end

    it "should have coordinates" do
      cell.coordinates.should eql([0, 0])
    end

    it "should have a status" do
      cell.status.should eql(:empty)
    end

    it "should have a string representation" do
      cell.to_s.should eql("X")
    end
  end
end

if __FILE__ == $PROGRAM_NAME
  g = Generation.new
  puts g.to_s(:plain)
  10.times.each do
    sleep(1)
    puts ""
    puts g.next.to_s(:plain)
  end
end
