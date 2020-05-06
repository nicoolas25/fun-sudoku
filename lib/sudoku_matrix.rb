# frozen_string_literal: true

require 'dancing_lists_matrix'

# See https://en.wikipedia.org/wiki/Exact_cover#Sudoku
class SudokuMatrix < DancingListsMatrix
  Position = Struct.new(:row, :col, :digit)

  def initialize
    super
    @clues = {}
    create_links!
  end

  def clues
    @clues.values
  end

  def add_clue(row:, col:, digit:)
    raise 'This position already have a clue' if @clues.key?([row, col])

    position = Position.new(row, col, digit)
    unlink_position(position)
    @clues[[row, col]] = position
  end

  def self.to_string(positions: [])
    (0..8).map do |row|
      (0..8).map do |col|
        position = positions.find { |p| p.row == row && p.col == col }
        position ? position.digit.to_s : '.'
      end.join('')
    end.join("\n")
  end

  private

  def create_links!
    (0..8).each do |row|
      (0..8).each do |col|
        (1..9).map do |digit|
          link_position(Position.new(row, col, digit))
        end
      end
    end
  end

  def unlink_position(position)
    constraints = constraints(position)
    conflicing_rows = rows.find_all do |row|
      row.value.id != position &&
        row.value.items.any? { |col| constraints.include?(col.value.id) }
    end
    conflicing_rows.each(&:remove)
  end

  def link_position(position)
    constraints(position).each do |constraint|
      link(row: position, col: constraint)
    end
  end

  def constraints(position)
    [
      :"r#{position.row}c#{position.col}",    # Row-Column constraint
      :"r#{position.row}n#{position.digit}",  # Row-Number constraints
      :"c#{position.col}n#{position.digit}",  # Col-Number constraints
      :"b#{box(position)}n#{position.digit}", # Box-Number constraints
    ]
  end

  def box(position)
    position.row / 3 * 3 + position.col / 3
  end
end
