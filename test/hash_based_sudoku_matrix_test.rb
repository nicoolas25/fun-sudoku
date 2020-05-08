# frozen_string_literal: true

require 'minitest/autorun'
require 'hash_based_algorithm_x'
require 'hash_based_sudoku_matrix'

class HashBasedSudokuMatrixTest < Minitest::Test
  def test_display
    assert_equal <<~STR.strip, HashBasedSudokuMatrix.to_string
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

  def test_adding_clues_then_solving
    matrix = HashBasedSudokuMatrix.new
    matrix.add_clue(row: 2, col: 5, digit: 9)
    matrix.add_clue(row: 7, col: 2, digit: 4)
    assert_equal <<~STR.strip, HashBasedSudokuMatrix.to_string(positions: matrix.clues)
      .........
      .........
      .....9...
      .........
      .........
      .........
      .........
      ..4......
      .........
    STR
    positions = HashBasedAlgorithmX.new(matrix).solve
    assert_equal matrix.clues, matrix.clues & positions
  end

  def test_can_be_solved_by_algorithm_x
    positions = HashBasedAlgorithmX.new(HashBasedSudokuMatrix.new).solve
    assert positions.size == 81
    assert_equal <<~STR.strip, HashBasedSudokuMatrix.to_string(positions: positions)
      123456789
      467189532
      589237164
      215693847
      398724651
      674518293
      732845916
      841962375
      956371428
    STR
  end

  def test_adding_clues_then_list_solutions
    matrix = HashBasedSudokuMatrix.new
    matrix.add_clue(row: 0, col: 0, digit: 8)
    matrix.add_clue(row: 1, col: 2, digit: 3)
    matrix.add_clue(row: 1, col: 3, digit: 6)
    matrix.add_clue(row: 2, col: 1, digit: 7)
    matrix.add_clue(row: 2, col: 4, digit: 9)
    matrix.add_clue(row: 2, col: 6, digit: 2)
    matrix.add_clue(row: 3, col: 1, digit: 5)
    matrix.add_clue(row: 3, col: 5, digit: 7)
    matrix.add_clue(row: 4, col: 4, digit: 4)
    matrix.add_clue(row: 4, col: 5, digit: 5)
    matrix.add_clue(row: 4, col: 6, digit: 7)
    matrix.add_clue(row: 5, col: 3, digit: 1)
    matrix.add_clue(row: 5, col: 7, digit: 3)
    matrix.add_clue(row: 6, col: 2, digit: 1)
    matrix.add_clue(row: 6, col: 7, digit: 6)
    matrix.add_clue(row: 6, col: 8, digit: 8)
    matrix.add_clue(row: 7, col: 2, digit: 8)
    matrix.add_clue(row: 7, col: 3, digit: 5)
    matrix.add_clue(row: 7, col: 7, digit: 1)
    matrix.add_clue(row: 8, col: 1, digit: 9)
    matrix.add_clue(row: 8, col: 6, digit: 4)
    assert_equal <<~STR.strip, HashBasedSudokuMatrix.to_string(positions: matrix.clues)
      8........
      ..36.....
      .7..9.2..
      .5...7...
      ....457..
      ...1...3.
      ..1....68
      ..85...1.
      .9....4..
    STR

    algorithm = HashBasedAlgorithmX.new(matrix)
    positions = algorithm.solve
    assert_equal <<~STR.strip, HashBasedSudokuMatrix.to_string(positions: positions)
      812753649
      943682175
      675491283
      154237896
      369845721
      287169534
      521974368
      438526917
      796318452
    STR

    # algorithm.behaviors = algorithm.behaviors.merge(HashBasedAlgorithmX::ALL_SOLUTIONS)
    # solutions = algorithm.solve
    # assert_equal 81, solutions.size
  end
end
