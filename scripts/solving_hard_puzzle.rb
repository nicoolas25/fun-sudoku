# frozen_string_literal: true

$LOAD_PATH.unshift("./lib")

require 'benchmark/ips'

require 'algorithm_x'
require 'sudoku_matrix'

EMPTY_MATRIX = SudokuMatrix.new

HARD_MATRIX = SudokuMatrix.new
HARD_MATRIX.add_clue(row: 0, col: 0, digit: 8)
HARD_MATRIX.add_clue(row: 1, col: 2, digit: 3)
HARD_MATRIX.add_clue(row: 1, col: 3, digit: 6)
HARD_MATRIX.add_clue(row: 2, col: 1, digit: 7)
HARD_MATRIX.add_clue(row: 2, col: 4, digit: 9)
HARD_MATRIX.add_clue(row: 2, col: 6, digit: 2)
HARD_MATRIX.add_clue(row: 3, col: 1, digit: 5)
HARD_MATRIX.add_clue(row: 3, col: 5, digit: 7)
HARD_MATRIX.add_clue(row: 4, col: 4, digit: 4)
HARD_MATRIX.add_clue(row: 4, col: 5, digit: 5)
HARD_MATRIX.add_clue(row: 4, col: 6, digit: 7)
HARD_MATRIX.add_clue(row: 5, col: 3, digit: 1)
HARD_MATRIX.add_clue(row: 5, col: 7, digit: 3)
HARD_MATRIX.add_clue(row: 6, col: 2, digit: 1)
HARD_MATRIX.add_clue(row: 6, col: 7, digit: 6)
HARD_MATRIX.add_clue(row: 6, col: 8, digit: 8)
HARD_MATRIX.add_clue(row: 7, col: 2, digit: 8)
HARD_MATRIX.add_clue(row: 7, col: 3, digit: 5)
HARD_MATRIX.add_clue(row: 7, col: 7, digit: 1)
HARD_MATRIX.add_clue(row: 8, col: 1, digit: 9)
HARD_MATRIX.add_clue(row: 8, col: 6, digit: 4)

Benchmark.ips do |x|
  x.time = 15
  x.warmup = 5

  algo1 = AlgorithmX.new(EMPTY_MATRIX, AlgorithmX::DETERMINISTIC.merge(AlgorithmX::ONE_SOLUTION))
  x.report('empty-matrix-deterministic') { algo1.solve }

  algo1b = AlgorithmX.new(EMPTY_MATRIX, AlgorithmX::NON_DETERMINISTIC.merge(AlgorithmX::ONE_SOLUTION))
  x.report('empty-matrix-non-deterministic') { algo1b.solve }

  algo2 = AlgorithmX.new(HARD_MATRIX, AlgorithmX::DETERMINISTIC.merge(AlgorithmX::ONE_SOLUTION))
  x.report('hard-matrix-deterministic') { algo2.solve }

  algo2b = AlgorithmX.new(HARD_MATRIX, AlgorithmX::NON_DETERMINISTIC.merge(AlgorithmX::ONE_SOLUTION))
  x.report('hard-matrix-non-deterministic') { algo2b.solve }

  x.compare!
end
