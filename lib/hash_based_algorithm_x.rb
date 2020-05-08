# frozen_string_literal: true

require 'hash_based_matrix'

class HashBasedAlgorithmX
  attr_reader :matrix, :behaviors

  DETERMINISTIC = {
    row_sorter: :to_a.to_proc,
  }.freeze

  NON_DETERMINISTIC = DETERMINISTIC.merge(
    row_sorter: ->(rows) { rows.to_a.shuffle },
  ).freeze

  ONE_SOLUTION = {
    strategy: :return_when_found,
    empty_solution: [],
    no_solution: nil,
    merge_solutions: ->(solution, row) { [row, *solution] },
  }.freeze

  ALL_SOLUTIONS = {
    strategy: :accumulate,
    empty_solution: [[]],
    no_solution: [],
    merge_solutions: lambda do |solutions, row|
      solutions.map { |solution| [*solution, row] }
    end,
  }.freeze

  def initialize(matrix, behaviors = DETERMINISTIC.merge(ONE_SOLUTION))
    @matrix = matrix
    self.behaviors = behaviors
  end

  def behaviors=(behaviors)
    @behaviors       = behaviors
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

    column = @matrix.cols.first
    candidate_rows = @row_sorter[@matrix.matching_rows(column)]
    candidate_rows.each do |row|
      cols = @matrix.matching_cols(row)
      rows = cols.each_with_object(Set.new) do |col, set|
        set.merge(@matrix.matching_rows(col))
      end

      child_solutions = solve_removing(cols, rows)

      next if child_solutions == @no_solution

      local_solutions = @merge_solutions[child_solutions, row]

      if @strategy == :return_when_found
        return local_solutions
      elsif @strategy == :accumulate
        solutions += local_solutions
      else
        raise "Unknown strategy: '#{@strategy}'"
      end
    end

    solutions
  end

  private

  def solve_removing(cols, rows)
    cols_to_restore = cols.map { |col| @matrix.remove_col(col) }
    rows_to_restore = rows.map { |row| @matrix.remove_row(row) }

    result = solve

    rows_to_restore.reverse_each(&:call)
    cols_to_restore.reverse_each(&:call)

    result
  end
end
