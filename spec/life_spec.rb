require File.expand_path(File.dirname(__FILE__) + '/../lib/life')

EXAMPLE_WORLD = 
"XXXXXXXXXX
XXXXXXXXXX
XXXXXXXXXX
XXXXXXXXXX"


# describe Life do
#   it "should do something" do
#     fail
#   end
# end

describe World do
  
  let(:world) { World.new 100, 120 }
  let(:small_world) { World.new 10, 4 }
  
  it "should initialize" do
    world.map.should have(120).elements
    world.map.first.should have(100).elements
  end
  
  it "should have a string representation" do
    small_world.to_s.should eql(EXAMPLE_WORLD)
  end
  
  it "should tell me no of cells alive" do
    world.cell_size.should eql(0)
  end
  
end

describe Cell do
  
  let(:cell) { Cell.new }
  
  it "should initialize" do
    cell.alive?.should be_true
  end
  
end