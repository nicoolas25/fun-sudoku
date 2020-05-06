# frozen_string_literal: true

$LOAD_PATH.unshift("./lib")

require 'benchmark/ips'

require 'algorithm_x'
require 'sudoku_matrix'

EMPTY_MATRIX = SudokuMatrix.new

Benchmark.ips do |x|
  x.time = 5
  x.warmup = 2

  algo1 = AlgorithmX.new(
    EMPTY_MATRIX,
    AlgorithmX::DETERMINISTIC.merge(AlgorithmX::ONE_SOLUTION)
  )

  x.report('deterministic-one-solution') { algo1.solve }


  algo2 = AlgorithmX.new(
    EMPTY_MATRIX,
    AlgorithmX::NON_DETERMINISTIC.merge(AlgorithmX::ONE_SOLUTION)
  )

  x.report('non-deterministic-one-solution') { algo2.solve }

  x.compare!
end
