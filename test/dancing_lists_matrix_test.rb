# frozen_string_literal: true

require 'minitest/autorun'
require 'dancing_lists_matrix'

class DancingListsMatrixTest < Minitest::Test
  def test_instanciation
    assert DancingListsMatrix.new
  end

  def test_linking_a_row_and_a_column
    matrix = DancingListsMatrix.new
    row = Object.new
    col = Object.new

    matrix.link(row: row, col: col)

    # New columns and rows are added
    assert_equal 1, matrix.rows.count
    assert_equal 1, matrix.cols.count

    # Inserting twice the same link doesn't have any effect
    matrix.link(row: row, col: col)
    assert_equal 1, matrix.rows.count
    assert_equal 1, matrix.cols.count

    # The row we inserted is present
    row_entry = matrix.rows.first
    assert_equal row, row_entry.value.id

    # The col we inserted is present
    col_entry = matrix.cols.first
    assert_equal col, col_entry.value.id

    # Rows and columns see each other
    assert row_entry.value.items.include?(col_entry)
    assert col_entry.value.items.include?(row_entry)
  end
end
