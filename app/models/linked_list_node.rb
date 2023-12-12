class LinkedListNode
  attr_accessor :timestamp, :next, :prev, :count

  def initialize(timestamp, count, previous_node, next_node = nil)
    @timestamp = timestamp
    @count = count
    @prev = previous_node
    @next = next_node
  end
end
