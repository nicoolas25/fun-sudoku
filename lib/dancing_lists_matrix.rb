# frozen_string_literal: true

require 'set'
require 'doubly_linked_list'

# This is a sparse matrix with custom rows and cols that are doubly-linked
# lists. This class allows for quick navigation through the matrix while leaving
# the opportunity to remove and restore columns or rows.
class DancingListsMatrix
  ColValue = Struct.new(:id, :rows)
  RowValue = Struct.new(:id, :cols)

  attr_reader :rows, :cols

  def initialize
    @cols = DoublyLinkedList.new
    @rows = DoublyLinkedList.new
  end

  def link(row:, col:, value: 1)
    col_entry = get(@cols, col) || add_col(col)
    row_entry = get(@rows, row) || add_row(row)

    if value == 1
      col_entry.value.rows << row_entry
      row_entry.value.cols << col_entry

      row_entry.on_remove { col_entry.value.rows.delete(row_entry) }
      row_entry.on_restore { col_entry.value.rows << row_entry }
    end
  end

  private

  def get(list, id)
    list.find { |e| e.value.id == id }
  end

  def add_col(id)
    @cols.append(ColValue.new(id, Set.new))
  end

  def add_row(id)
    @rows.append(RowValue.new(id, Set.new))
  end
end
