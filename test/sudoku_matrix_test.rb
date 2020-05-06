# frozen_string_literal: true

require 'minitest/autorun'
require 'algorithm_x'
require 'sudoku_matrix'

class SudokuMatrixTest < Minitest::Test
  def test_display
    assert_equal <<~STR.strip, SudokuMatrix.to_string
      .........
      .........
      .........
      .........
      .........
      .........
      .........
      .........
      .........
    STR
  end

  def test_can_be_solved_by_algorithm_x
    positions = AlgorithmX.new(SudokuMatrix.new).solve
    assert positions.size == 81
    assert_equal <<~STR.strip, SudokuMatrix.to_string(positions: positions)
      123456789
      467189523
      589237146
      214398657
      375612498
      698574312
      731925864
      842761935
      956843271
    STR
  end
end
