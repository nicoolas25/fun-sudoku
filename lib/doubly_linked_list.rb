class DoublyLinkedList
  include Enumerable

  def initialize(header_value: nil)
    @header = Entry.new(header_value, nil, nil).tap do |h|
      h.left = h
      h.right = h
    end
  end

  def append(value)
    @header.left.insert_after(value)
  end

  def each
    cursor = @header.right
    while cursor != @header
      yield cursor
      cursor = cursor.right
    end
  end

  class Entry
    attr_accessor :value, :left, :right

    def initialize(value, left, right)
      @value = value
      @left = left
      @right = right
      @removed = false
    end

    def on_remove(&block)
      (@on_remove_callbacks ||= []) << block
    end

    def on_restore(&block)
      (@on_restore_callbacks ||= []) << block
    end

    def remove
      return if @removed

      left.right = right
      right.left = left

      @on_remove_callbacks.each(&:call) if defined?(@on_remove_callbacks)
      @removed = true
    end

    def restore
      return unless @removed

      left.right = self
      right.left = self

      @on_restore_callbacks.each(&:call) if defined?(@on_restore_callbacks)
      @removed = false
    end

    def insert_after(value)
      Entry.new(value, self, right).tap do |new_entry|
        right.left = new_entry
        self.right = new_entry
      end
    end
  end
end
