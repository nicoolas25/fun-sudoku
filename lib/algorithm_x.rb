# frozen_string_literal: true

require 'dancing_lists_matrix'

class AlgorithmX
  attr_reader :matrix, :behaviors

  DETERMINISTIC = {
    column_sorter: :itself.to_proc,
    column_picker: ->(cols) { cols.min_by { |col| col.value.rows.size } },
    row_sorter: :itself.to_proc,
  }.freeze

  NON_DETERMINISTIC = DETERMINISTIC.merge(
    column_sorter: ->(cols) { cols.to_a.shuffle },
    row_sorter: ->(rows) { rows.to_a.shuffle },
  ).freeze

  ONE_SOLUTION = {
    strategy: :return_when_found,
    empty_solution: [],
    no_solution: nil,
    merge_solutions: ->(solution, row) { [row.value.id, *solution] },
  }.freeze

  ALL_SOLUTIONS = {
    strategy: :accumulate,
    empty_solution: [[]],
    no_solution: [],
    merge_solutions: lambda do |solutions, row|
      solutions.map { |solution| [*solution, row.value.id] }
    end,
  }.freeze

  def initialize(matrix, behaviors = DETERMINISTIC.merge(ONE_SOLUTION))
    @matrix = matrix
    self.behaviors = behaviors
  end

  def behaviors=(behaviors)
    @behaviors       = behaviors
    @column_picker   = behaviors.fetch(:column_picker)
    @column_sorter   = behaviors.fetch(:column_sorter)
    @row_sorter      = behaviors.fetch(:row_sorter)
    @empty_solution  = behaviors.fetch(:empty_solution)
    @no_solution     = behaviors.fetch(:no_solution)
    @merge_solutions = behaviors.fetch(:merge_solutions)
    @strategy        = behaviors.fetch(:strategy)
  end

  def solve
    if @matrix.cols.first.nil?
      return @empty_solution
    end

    if @matrix.rows.first.nil?
      return @no_solution
    end

    solutions = @no_solution

    easier_column = @column_picker[@column_sorter[@matrix.cols]]
    candidate_rows = @row_sorter[easier_column.value.rows.to_a]
    candidate_rows.each do |row|
      cols = row.value.cols
      rows = cols.inject(Set.new) { |set, col| set.merge(col.value.rows) }
      removed_entries = [*cols, *rows].each(&:remove)
      child_solutions = solve
      removed_entries.reverse_each(&:restore)

      if child_solutions != @no_solution
        local_solutions = @merge_solutions[child_solutions, row]
        case @strategy
        when :return_when_found
          return local_solutions
        when :accumulate
          solutions += local_solutions
        else
          raise "Unknown strategy: '#{@strategy}'"
        end
      end
    end

    solutions
  end
end
