# frozen_string_literal: true

require 'set'
require 'doubly_linked_list'

# This is a sparse matrix with custom rows and cols that are doubly-linked
# lists. This class allows for quick navigation through the matrix while leaving
# the opportunity to remove and restore columns or rows.
class DancingListsMatrix
  Value = Struct.new(:id, :items)

  attr_reader :rows, :cols

  def initialize
    @rows = DoublyLinkedList.new
    @cols = DoublyLinkedList.new
  end

  def link(row:, col:)
    col_entry = get(@cols, col)
    row_entry = get(@rows, row)
    col_entry.value.items << row_entry
    row_entry.value.items << col_entry
  end

  private

  def get(list, id)
    entry = list.find { |e| e.value.id == id }
    entry || add(list, id)
  end

  def add(list, id)
    value = Value.new(id, Set.new)
    list << value
    list.last
  end
end
