class DoubleLinkedList
  attr_accessor :head

  def initialize(head = nil)
    @head = head
  end

  def sorted_add(timestamp, count)
    if @head.nil?
      @head = LinkedListNode.new(timestamp, count, nil)
    else
      currently_evaluated_node = @head
      loop do
        if currently_evaluated_node.timestamp < timestamp
          # new is more recent
          new_node = LinkedListNode.new(timestamp, count, currently_evaluated_node.prev, currently_evaluated_node)
          @head = new_node if currently_evaluated_node.prev.nil?
          currently_evaluated_node.prev&.next = new_node
          currently_evaluated_node.prev = new_node
          break
        elsif currently_evaluated_node.timestamp > timestamp
          # currently existing is mroe recent
          if currently_evaluated_node.next.nil?
            # we reached the end of the list
            new_node = LinkedListNode.new(timestamp, count, currently_evaluated_node)
            currently_evaluated_node.next = new_node
            break
          else
            currently_evaluated_node = currently_evaluated_node.next
          end
        end
      end
    end
    self
  end

  def total_count
    return 0 if @head.nil?

    current_node = @head
    accumulator = 0
    loop do
      accumulator = accumulator + current_node.count
      break if current_node.next.nil?

      current_node = current_node.next
    end
    accumulator
  end
end
