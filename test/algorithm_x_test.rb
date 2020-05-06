# frozen_string_literal: true

require 'minitest/autorun'
require 'algorithm_x'

class AlgorithmXTest < Minitest::Test
  def test_with_an_empty_matrix_it_is_solved_it_is_empty
    x = algorithm_x
    assert_equal [], x.solve
  end

  def test_with_a_single_row_and_column_set_to_0_it_is_nil
    x = algorithm_x(
      [nil, :A],
      [:Z,  0],
    )
    assert_nil x.solve
  end

  def test_that_it_reinsert_everything_when_failed_to_solve
    x = algorithm_x(
      [nil, :A],
      [:Z,  0],
    )
    x.solve
    assert_equal 1, x.matrix.cols.count
    assert_equal 1, x.matrix.rows.count
  end

  def test_with_a_single_row_and_column_set_to_1_it_is_the_only_row
    x = algorithm_x(
      [nil, :A],
      [:Z,  1],
    )
    assert_equal [:Z], x.solve
  end

  def test_that_it_reinsert_everything_when_solved
    x = algorithm_x(
      [nil, :A],
      [:Z,  1],
    )
    x.solve
    assert_equal 1, x.matrix.cols.count
    assert_equal 1, x.matrix.rows.count
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

  def test_non_deterministic_solving
    matrix = [
      [nil, 1, 2],
      [:A,  0, 1],
      [:B,  1, 0],
      [:C,  0, 1],
      [:D,  1, 0],
      [:E,  0, 1],
      [:F,  1, 0],
      [:G,  0, 1],
      [:H,  1, 0],
      [:I,  0, 1],
      [:J,  1, 1],
    ]
    x1 = algorithm_x(*matrix)
    x2 = algorithm_x(*matrix)
    assert_equal x1.solve, x2.solve

    x3 = non_deterministic algorithm_x(*matrix)
    x4 = non_deterministic algorithm_x(*matrix)
    refute_equal x3.solve, x4.solve
  end

  def test_with_an_empty_matrix_it_is_finds_all_solutions
    x = all_solutions algorithm_x
    assert_equal [[]], x.solve
  end

  def test_with_a_single_row_and_column_set_to_0_it_has_no_solutions
    x = all_solutions algorithm_x(
      [nil, :A],
      [:Z,  0],
    )
    assert_equal [], x.solve
  end

  def test_that_it_reinsert_everything_when_failed_to_solve_all
    x = all_solutions algorithm_x(
      [nil, :A],
      [:Z,  0],
    )
    x.solve
    assert_equal 1, x.matrix.cols.count
    assert_equal 1, x.matrix.rows.count
  end

  def test_with_a_single_solution_it_finds_it
    x = all_solutions algorithm_x(
      [nil, :A],
      [:Z,  1],
    )
    assert_equal [[:Z]], x.solve
  end

  def test_that_it_reinsert_everything_when_solved_all
    x = all_solutions algorithm_x(
      [nil, :A],
      [:Z,  1],
    )
    x.solve
    assert_equal 1, x.matrix.cols.count
    assert_equal 1, x.matrix.rows.count
  end

  def test_with_knuth_example_finds_all_solutions
    # See https://en.wikipedia.org/wiki/Knuth%27s_Algorithm_X
    x = all_solutions algorithm_x(
      [nil, 1, 2, 3, 4, 5, 6, 7],
      [:A,  1, 0, 0, 1, 0, 0, 1],
      [:B,  1, 0, 0, 1, 0, 0, 0],
      [:C,  0, 0, 0, 1, 1, 0, 1],
      [:D,  0, 0, 1, 0, 1, 1, 0],
      [:E,  0, 1, 1, 0, 0, 1, 1],
      [:F,  0, 1, 0, 0, 0, 0, 1],
    )
    assert_equal [[:D, :F, :B]], x.solve
  end

  def test_with_multiple_solutions
    x = all_solutions algorithm_x(
      [nil, :A, :B, :C, :D],
      [:V,  1,  0,  0,  0],
      [:W,  1,  0,  0,  0],
      [:X,  0,  1,  0,  0],
      [:Y,  0,  0,  1,  0],
      [:Z,  0,  0,  0,  1],
    )
    assert_equal [[:Z, :Y, :X, :V], [:Z, :Y, :X, :W]], x.solve
  end

  def test_non_deterministic_solving_all
    matrix = [
      [nil, 1, 2],
      [:A,  0, 1],
      [:B,  1, 0],
      [:C,  0, 1],
      [:D,  1, 0],
      [:E,  0, 1],
      [:F,  1, 0],
      [:G,  0, 1],
      [:H,  1, 0],
      [:I,  0, 1],
      [:J,  1, 1],
    ]
    x1 = all_solutions algorithm_x(*matrix)
    x2 = all_solutions algorithm_x(*matrix)
    assert_equal x1.solve, x2.solve

    x3 = non_deterministic all_solutions algorithm_x(*matrix)
    x4 = non_deterministic all_solutions algorithm_x(*matrix)
    refute_equal x3.solve, x4.solve
  end

  private

  def non_deterministic(algo)
    algo.behaviors = algo.behaviors.merge(AlgorithmX::NON_DETERMINISTIC)
    algo
  end

  def all_solutions(algo)
    algo.behaviors = algo.behaviors.merge(AlgorithmX::ALL_SOLUTIONS)
    algo
  end

  def algorithm_x(*rows)
    matrix = DancingListsMatrix.new
    if (col_headers = rows.shift)
      rows.each do |row_header, *rows_values|
        rows_values.each_with_index do |value, index|
          col_header = col_headers[index + 1]
          matrix.link(col: col_header, row: row_header, value: value)
        end
      end
    end
    AlgorithmX.new(matrix)
  end
end
