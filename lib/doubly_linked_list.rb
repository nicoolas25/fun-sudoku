# frozen_string_literal: true

require 'entry'

class DoublyLinkedList
  include Enumerable

  def initialize(header_value: nil)
    @header = Entry.new(header_value, nil, nil).tap do |h|
      h.left = h
      h.right = h
    end
  end

  def append(entry)
    @header.left.insert_after(entry)
  end

  def append_value(value)
    append(Entry.new(value, nil, nil))
  end

  def each
    cursor = @header.right
    while cursor != @header
      yield cursor
      cursor = cursor.right
    end
  end
end
