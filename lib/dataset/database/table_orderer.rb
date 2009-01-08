require 'rubygems'
gem 'rgl'
require 'rgl/adjacency'
require 'rgl/topsort'

module Dataset::Database
  class TableOrderer
    def initialize
      @graph = RGL::DirectedAdjacencyGraph.new
    end
    
    def insertion_order
      @graph.topsort_iterator.to_a
    end
    
    def deletion_order
      insertion_order.reverse
    end
    
    def link(parent, child)
      @graph.add_edge(parent, child) unless parent == child
    end
    
    def add_table(name)
      @graph.add_vertex(name)
    end
  end
end