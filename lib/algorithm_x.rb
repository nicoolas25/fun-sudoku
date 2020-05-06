# frozen_string_literal: true

require 'dancing_lists_matrix'

class AlgorithmX
  def initialize(matrix)
    @matrix = matrix
  end

  def solve(solution = [])
    if @matrix.cols.count.zero?
      return solution
    elsif @matrix.rows.count.zero?
      return nil
    end

    col = @matrix.cols.first
    # puts "Trying to solve #{col.value.id}"

    col.value.items.each do |solution_row|
      # TODO: This could be optimized if we used doubly linked lists
      # as columns's value rather than Set
      next if solution_row.removed?

      # puts "  Using #{solution_row.value.id} as a part of the solution"
      current_solution = [*solution, solution_row.value.id]

      cols = solution_row.value.items.to_a
      rows = cols.map { |c| c.value.items }.reduce(&:union).to_a

      cols.each(&:remove)
      # puts "  - Removing #{cols.map(&:value).map(&:id)}"

      rows.each(&:remove)
      # puts "  - Removing #{rows.map(&:value).map(&:id)}"

      final_solution = solve(current_solution)

      if final_solution
        # puts "=> Solution is found, bubbling up!"
        return final_solution
      else
        # puts "  Oups, #{solution_row.value.id} wasn't the one"
        rows.reverse_each(&:restore)
        # puts "  - Restoring #{rows.map(&:value).map(&:id)}"
        cols.reverse_each(&:restore)
        # puts "  - Restoring #{cols.map(&:value).map(&:id)}"
      end
    end

    nil
  end
end
