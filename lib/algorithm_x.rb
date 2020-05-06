# frozen_string_literal: true

require 'dancing_lists_matrix'

class AlgorithmX
  attr_reader :matrix

  def initialize(matrix)
    @matrix = matrix
  end

  def solve(deterministic: true)
    return [] if @matrix.cols.first.nil?
    return nil if @matrix.rows.all? { |row| row.value.items.all?(&:removed?) }

    easier_column = @matrix.cols
      .yield_self { |cols| deterministic ? cols : cols.to_a.shuffle }
      .min_by { |col| col.value.items.count { |row| !row.removed? } }

    candidate_rows = easier_column.value.items
      .reject(&:removed?)
      .yield_self { |cols| deterministic ? cols : cols.shuffle }

    candidate_rows.each do |row|
      cols = row.value.items
      rows = cols.inject(Set.new) do |set, col|
        set.merge(col.value.items.reject(&:removed?))
      end

      removed_entries = [*cols, *rows].each(&:remove)
      solution = solve
      removed_entries.reverse_each(&:restore)

      return [row.value.id, *solution] if solution
    end

    nil
  end

  # TODO: Maybe this duplication could easily be avoided
  def solve_all(deterministic: true)
    return [[]] if @matrix.cols.first.nil?
    return [] if @matrix.rows.all? { |e| e.value.items.all?(&:removed?) }

    easier_column = @matrix.cols
      .yield_self { |cols| deterministic ? cols : cols.to_a.shuffle }
      .min_by { |col| col.value.items.count { |row| !row.removed? } }

    candidate_rows = easier_column.value.items
      .reject(&:removed?)
      .yield_self { |cols| deterministic ? cols : cols.shuffle }

    solutions = []

    candidate_rows.each do |row|
      cols = row.value.items
      rows = cols.inject(Set.new) do |set, entry|
        set.merge(entry.value.items.reject(&:removed?))
      end

      removed_entries = [*cols, *rows].each(&:remove)
      sub_solutions = solve_all
      removed_entries.reverse_each(&:restore)

      if sub_solutions.any?
        solutions += sub_solutions.map { |s| [*s, row.value.id] }
      end
    end

    solutions
  end
end
