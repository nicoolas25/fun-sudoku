require 'minitest/autorun'

EMPTY_CELL = Object.new

def EMPTY_CELL.to_s
  "."
end

# Constants holding lists of lists of (row, column) pairs. Each sublist
# corespond to either a full row, a full column, or a full region's
# positions.
ROWS = (0..8).map { |row| (0..8).map { |column| [row, column] } }
COLUMNS = (0..8).map { |column| (0..8).map { |row| [row, column] } }
REGIONS = [
  [[0, 0], [0, 1], [0, 2], [1, 0], [1, 1], [1, 2], [2, 0], [2, 1], [2, 2]],
  [[0, 3], [0, 4], [0, 5], [1, 3], [1, 4], [1, 5], [2, 3], [2, 4], [2, 5]],
  [[0, 6], [0, 7], [0, 8], [1, 6], [1, 7], [1, 8], [2, 6], [2, 7], [2, 8]],
  [[3, 0], [3, 1], [3, 2], [4, 0], [4, 1], [4, 2], [5, 0], [5, 1], [5, 2]],
  [[3, 3], [3, 4], [3, 5], [4, 3], [4, 4], [4, 5], [5, 3], [5, 4], [5, 5]],
  [[3, 6], [3, 7], [3, 8], [4, 6], [4, 7], [4, 8], [5, 6], [5, 7], [5, 8]],
  [[6, 0], [6, 1], [6, 2], [7, 0], [7, 1], [7, 2], [8, 0], [8, 1], [8, 2]],
  [[6, 3], [6, 4], [6, 5], [7, 3], [7, 4], [7, 5], [8, 3], [8, 4], [8, 5]],
  [[6, 6], [6, 7], [6, 8], [7, 6], [7, 7], [7, 8], [8, 6], [8, 7], [8, 8]],
]

class Sudoku
  def initialize(lines: nil)
    @lines = lines || Array.new(9) { Array.new(9) { EMPTY_CELL } }
  end

  def with(row:, column:, value:)
    lines = @lines.map.with_index { |cells, i| (i != row) ? cells : cells.dup }
    lines[row][column] = value
    Sudoku.new(lines: lines)
  end

  def read(row:, column:)
    @lines[row][column]
  end

  def each_empty_positions
    return enum_for(:each_empty_positions) unless block_given?

    @lines.each_with_index do |cells, row|
      cells.each_with_index do |cell, column|
        yield [row, column] if cell == EMPTY_CELL
      end
    end
  end

  def to_s
    "".tap do |buffer|
      @lines.each do |cells|
        cells.each do |cell|
          buffer << cell.to_s
        end
        buffer << "\n"
      end
    end
  end
end

class ConstraintChecker
  def initialize(sudoku:)
    @sudoku = sudoku
  end

  def available_values(row:, column:)
    if @sudoku.read(row: row, column: column) != EMPTY_CELL
      raise ArgumentError, "Position (#{row}, #{column}) is already filled"
    end

    region = REGIONS.find { |positions| positions.include?([row, column]) }

    unless (region_counts = valid_positions?(region))
      raise ArgumentError, "The region is already broken"
    end

    unless (row_counts = valid_positions?(ROWS[row]))
      raise ArgumentError, "The row is already broken"
    end

    unless (column_counts = valid_positions?(COLUMNS[column]))
      raise ArgumentError, "The column is already broken"
    end

    (1..9).reject do |value|
      region_counts[value] > 0 || row_counts[value] > 0 || column_counts[value] > 0
    end
  end

  private

  def valid_positions?(positions)
    Hash.new(0).tap do |counts|
      positions.each do |row, column|
        value = @sudoku.read(row: row, column: column)
        next if EMPTY_CELL == value

        total = (counts[value] += 1)
        return false if total > 1
      end
    end
  end
end

class SudokuProblem
  attr_reader :sudoku

  def initialize(sudoku:)
    @sudoku = sudoku
  end

  def solved?
    @sudoku.each_empty_positions.peek
    false
  rescue StopIteration
    true
  end

  def possible_paths
    row, column = @sudoku.each_empty_positions.next
    ConstraintChecker.new(sudoku: @sudoku)
      .available_values(row: row, column: column)
      .map do |value|
        sudoku = @sudoku.with(row: row, column: column, value: value)
        SudokuProblem.new(sudoku: sudoku)
      end
  rescue StopIteration
    []
  end
end

class Backtracker
  NoSolutionFound = Class.new(StandardError)

  def initialize(problem:)
    @problem = problem
  end

  def solve
    return @problem if @problem.solved?

    paths = @problem.possible_paths
    raise NoSolutionFound if paths.empty?

    paths.each do |problem|
      backtracker = Backtracker.new(problem: problem)
      return backtracker.solve
    rescue NoSolutionFound
      next
    end

    raise NoSolutionFound
  end
end

class ConstraitCheckerTest < Minitest::Test
  def test_available_values_in_a_row
    _test_available_values(ROWS.sample)
  end

  def test_available_values_in_a_column
    _test_available_values(COLUMNS.sample)
  end

  def test_available_values_in_a_region
    _test_available_values(REGIONS.sample)
  end

  private

  def _test_available_values(positions)
    # Put all numbers in the positions
    sudoku = fill_all_positions(positions)
    # Pick one position and remember what it was filled with
    row, column = positions.sample
    value = sudoku.read(row: row, column: column)
    # Clean that position
    sudoku = sudoku.with(row: row, column: column, value: EMPTY_CELL)

    constraint_checker = ConstraintChecker.new(sudoku: sudoku)
    assert_equal [value], constraint_checker.available_values(row: row, column: column)
  end

  def fill_all_positions(positions, sudoku: Sudoku.new)
    positions.shuffle.zip(1..9).reduce(sudoku) do |result, ((row, column), value)|
      result.with(row: row, column: column, value: value)
    end
  end
end

class SudokuTest < Minitest::Test
  def test_empty_grid
    assert_equal <<~GRID, Sudoku.new.to_s
      .........
      .........
      .........
      .........
      .........
      .........
      .........
      .........
      .........
    GRID
  end

  def test_setting_a_cell_with_something
    assert_equal <<~GRID, Sudoku.new.with(row: 0, column: 7, value: 4).to_s
      .......4.
      .........
      .........
      .........
      .........
      .........
      .........
      .........
      .........
    GRID
  end

  def test_reading_a_cell_without_content
    assert_equal EMPTY_CELL, Sudoku.new.read(row: 2, column: 0)
  end

  def test_reading_a_cell_with_content
    content = Object.new
    sudoku = Sudoku.new.with(row: 4, column: 2, value: content)
    assert_equal content, sudoku.read(row: 4, column: 2)
  end

  def test_reading_empty_cells
    assert_equal 81, Sudoku.new.each_empty_positions.to_a.size
    assert_equal 80, Sudoku.new.with(row: 0, column: 8, value: 2).each_empty_positions.to_a.size
  end
end

class SolveSudokuTest < Minitest::Test
  def test_empty_sudoku_is_solved
    sudoku = Sudoku.new
    problem = SudokuProblem.new(sudoku: sudoku)
    assert_equal <<~GRID, Backtracker.new(problem: problem).solve.sudoku.to_s
      123456789
      456789123
      789123456
      214365897
      365897214
      897214365
      531642978
      642978531
      978531642
    GRID
  end
end
