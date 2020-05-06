# frozen_string_literal: true

require 'dancing_lists_matrix'

class AlgorithmX
  attr_reader :matrix

  def initialize(matrix)
    @matrix = matrix
  end

  def solve
    return [] if @matrix.cols.first.nil?
    return nil if @matrix.rows.all? { |e| e.value.items.all?(&:removed?) }

    @matrix.cols.first.value.items.reject(&:removed?).each do |row|
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
