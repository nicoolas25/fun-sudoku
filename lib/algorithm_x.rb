# frozen_string_literal: true

require 'dancing_lists_matrix'

class AlgorithmX
  attr_reader :matrix

  def initialize(matrix)
    @matrix = matrix
  end

  def solve(deterministic: true)
    return [] if @matrix.cols.first.nil?
    return nil if @matrix.rows.all? { |e| e.value.items.all?(&:removed?) }

    easier_column = @matrix.cols
      .yield_self { |cols| deterministic ? cols : cols.to_a.shuffle }
      .min_by { |col| col.value.items.count { |row| !row.removed? } }

    candidate_rows = easier_column.value.items
      .reject(&:removed?)
      .yield_self { |cols| deterministic ? cols : cols.shuffle }

    candidate_rows.each do |row|
      cols = row.value.items
      rows = cols.inject(Set.new) do |set, entry|
        set.merge(entry.value.items.reject(&:removed?))
      end

      removed_entries = [*cols, *rows].each(&:remove)
      solution = solve
      removed_entries.reverse_each(&:restore)

      return [row.value.id, *solution] if solution
    end

    nil
  end
end
