# frozen_string_literal: true

require 'dancing_lists_matrix'

# See https://en.wikipedia.org/wiki/Exact_cover#Sudoku
class SudokuMatrix < DancingListsMatrix
  Position = Struct.new(:row, :col, :digit)

  def initialize
    super
    create_links!
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
    # Row-Column constraints
    (0..8).each do |row|
      (0..8).each do |col|
        (1..9).map do |digit|
          p = Position.new(row, col, digit)
          # Row-Column constraint
          link(row: p, col: :"r#{row}c#{col}")

          # Row-Number constraints
          link(row: p, col: :"r#{row}n#{digit}")

          # Col-Number constraints
          link(row: p, col: :"c#{col}n#{digit}")

          # Box-Number constraints
          link(row: p, col: :"b#{box_id(row, col)}n#{digit}")
        end
      end
    end
  end

  def box_id(row, col)
    row / 3 * 3 + col / 3
  end
end
