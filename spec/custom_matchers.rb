def have_partial_order(earlier, later)
  PartialOrderMatcher.new(earlier, later)
end

class PartialOrderMatcher
  def initialize(earlier, later)
    @earlier = earlier
    @later = later
  end
  
  def matches?(actual)
    @actual = actual
    actual.include?(@earlier) && 
      actual.include?(@later) && 
      actual.index(@earlier) < actual.index(@later)
  end
  
  def failure_message
    return "#{@earlier.inspect} is not present" unless @actual.include?(@earlier)
    return "#{@later.inspect} is not present" unless @actual.include?(@later)
    "#{@earlier.inspect} is after #{@later.inspect}"
  end
end
