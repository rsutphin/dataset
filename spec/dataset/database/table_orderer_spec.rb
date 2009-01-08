require File.expand_path(File.dirname(__FILE__)) + '/../../spec_helper'

describe Dataset::Database::TableOrderer do
  before do
    @orderer = Dataset::Database::TableOrderer.new
  end
  
  def actual_order
    @orderer.insertion_order
  end
  
  it "includes all tables for all unrelated tables" do
    @orderer.add_table "a"
    @orderer.add_table "b"
    @orderer.add_table "c"
    
    actual_order.should include("a")
    actual_order.should include("b")
    actual_order.should include("c")
  end
  
  it "provides correct order for single links" do
    @orderer.link "a", "b"
    
    actual_order.should == %w(a b)
  end
  
  it "provides the correct order for transitive links" do
    @orderer.link "b", "a"
    @orderer.link "c", "b"
    
    actual_order.should == %w(c b a)
  end
  
  it "has a deletion order which is the reverse of the insertion order" do
    @orderer.link "b", "a"
    @orderer.link "c", "b"
    
    @orderer.deletion_order.should == actual_order.reverse
  end
  
  it "includes all tables, including unrelated clusters" do
    @orderer.link "a", "b"
    @orderer.link "b", "c"
    @orderer.link "b", "d"
    @orderer.link "1", "2"
    @orderer.link "1", "3"
    @orderer.add_table "alone"
    
    actual_order.should have_partial_order("a", "b")
    actual_order.should have_partial_order("b", "c")
    actual_order.should have_partial_order("b", "d")
    actual_order.should have_partial_order("1", "2")
    actual_order.should have_partial_order("1", "3")
    actual_order.should include("alone")
  end
  
  it "ignores self-references" do
    @orderer.link "a", "b"
    @orderer.link "a", "a"
    
    actual_order.should == %w(a b)
  end
end

