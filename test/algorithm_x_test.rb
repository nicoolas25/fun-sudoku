# frozen_string_literal: true

require 'minitest/autorun'
require 'algorithm_x'

class AlgorithmXTest < Minitest::Test
  def test_with_an_empty_matrix
    x = algorithm_x
    assert_equal [], x.solve
  end

  def test_with_a_single_row_and_column_set_to_0
    x = algorithm_x(
      [nil, :A],
      [:Z,  0],
    )
    assert_equal [], x.solve
  end

  def test_with_a_single_row_and_column_set_to_1
    x = algorithm_x(
      [nil, :A],
      [:Z,  1],
    )
    assert_equal [:Z], x.solve
  end

  def test_with_an_obvious_solution
    x = algorithm_x(
      [nil, :A, :B, :C, :D],
      [:W,  1,  0,  0,  0],
      [:X,  0,  1,  0,  0],
      [:Y,  0,  0,  1,  0],
      [:Z,  0,  0,  0,  1],
    )
    assert_equal [:W, :X, :Y, :Z], x.solve
  end

  def test_with_conflicting_rows
    x = algorithm_x(
      [nil, :A, :B, :C, :D],
      [:W,  1,  0,  1,  0],
      [:X,  0,  1,  0,  0],
      [:Y,  0,  0,  1,  0],
      [:Z,  0,  1,  0,  1],
    )
    assert_equal [:W, :Z], x.solve
  end

  def test_with_knuth_example
    # See https://en.wikipedia.org/wiki/Knuth%27s_Algorithm_X
    x = algorithm_x(
      [nil, 1, 2, 3, 4, 5, 6, 7],
      [:A,  1, 0, 0, 1, 0, 0, 1],
      [:B,  1, 0, 0, 1, 0, 0, 0],
      [:C,  0, 0, 0, 1, 1, 0, 1],
      [:D,  0, 0, 1, 0, 1, 1, 0],
      [:E,  0, 1, 1, 0, 0, 1, 1],
      [:F,  0, 1, 0, 0, 0, 0, 1],
    )
    assert_equal [:B, :F, :D], x.solve
  end

  private

  def algorithm_x(*rows)
    matrix = DancingListsMatrix.new
    if (col_headers = rows.shift)
      rows.each do |row_header, *rows_values|
        rows_values.each_with_index do |value, index|
          col_header = col_headers[index + 1]
          matrix.link(col: col_header, row: row_header) if value == 1
        end
      end
    end
    AlgorithmX.new(matrix)
  end
end
