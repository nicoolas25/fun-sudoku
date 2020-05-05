class DoublyLinkedList
  include Enumerable

  def initialize(header_value: nil)
    @header = Entry.new(header_value, nil, nil).tap do |h|
      h.left = h
      h.right = h
    end
  end

  def <<(value)
    @header.left.insert_after(value)
    self
  end

  def last
    @header.left
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

    def remove
      @removed = true
      left.right = right
      right.left = left
    end

    def restore
      @removed = false
      left.right = self
      right.left = self
    end

    def insert_after(value)
      Entry.new(value, self, right).tap do |new_entry|
        right.left = new_entry
        self.right = new_entry
      end
    end

    def removed?
      @removed
    end
  end
end
