# frozen_string_literal: true

require 'dancing_lists_matrix'

class AlgorithmX
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
    merge_solutions: ->(solution, row) { [row.id, *solution] },
  }.freeze

  ALL_SOLUTIONS = {
    strategy: :accumulate,
    empty_solution: [[]],
    no_solution: [],
    merge_solutions: lambda do |solutions, row|
      solutions.map { |solution| [*solution, row.id] }
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
    candidate_rows = @row_sorter[column.rows.map(&:value)]
    candidate_rows.each do |row|
      cols = row.cols.map(&:value)
      rows = cols.inject(Set.new) do |set, col|
        set.merge(col.rows.map(&:value))
      end

      links = [*cols, *rows, *rows.flat_map { |r| r.cols.to_a }]
      links.each(&:remove)
      child_solutions = solve
      links.reverse_each(&:restore)

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
