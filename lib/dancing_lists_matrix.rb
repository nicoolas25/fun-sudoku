# frozen_string_literal: true

require 'set'
require 'entry'
require 'double_entry'
require 'doubly_linked_list'

# This is a sparse matrix with custom rows and cols that are doubly-linked
# lists. This class allows for quick navigation through the matrix while leaving
# the opportunity to remove and restore columns or rows.
class DancingListsMatrix
  attr_reader :rows, :cols

  def initialize
    @cols = DoublyLinkedList.new
    @rows = DoublyLinkedList.new
  end

  def link(row:, col:, value: 1)
    col_header = get(@cols, col) || add_col(col)
    row_header = get(@rows, row) || add_row(row)

    if value == 1
      entry = DoubleEntry.new(vertical: col_header, horizontal: row_header)
      col_header.rows.append(entry.h_entry)
      row_header.cols.append(entry.v_entry)
    end
  end

  def to_s
    buffer = String.new

    headers = @cols.map { |c| '%4s' % c.id }.join(' ')
    buffer << headers << "\n"

    @rows.each do |r|
      line = @cols.map do |c|
        if r.cols.any? { |c2| c.id == c2.value.id }
          '%4s' % 1
        else
          '%4s' % 0
        end
      end
      line << ('%4s' % r.id)
      buffer << line.join(' ') << "\n"
    end

    buffer
  end

  private

  def get(list, id)
    list.find { |header| header.id == id }
  end

  def add_col(id)
    header = ColHeader.new(id)
    header.rows = DoublyLinkedList.new
    @cols.append(header)
  end

  def add_row(id)
    header = RowHeader.new(id)
    header.cols = DoublyLinkedList.new
    @rows.append(header)
  end

  Header = Class.new(Entry) do
    alias_method :id, :value

    def initialize(id)
      super(id, nil, nil)
    end
  end

  ColHeader = Class.new(Header) do
    attr_accessor :rows
    alias_method :items, :rows
  end

  RowHeader = Class.new(Header) do
    attr_accessor :cols
    alias_method :items, :cols
  end
end
