# frozen_string_literal: true

require 'set'

class HashBasedMatrix
  def initialize
    @cols = Hash.new { |h, k| h[k] = Set.new }
  end

  def link(row:, col:, value: 1)
    @cols[col] # Make sure the col exists as a key even is no row will match
    @cols[col] << row if value == 1
  end

  def cols
    @cols.keys
  end

  def rows
    @cols.each_with_object(Set.new) do |(_col, rows), set|
      set.merge(rows)
    end
  end

  def matching_rows(col)
    @cols.key?(col) ? @cols[col] : Set.new
  end

  def matching_cols(row)
    @cols.each_with_object(Set.new) do |(col, rows), cols|
      cols << col if rows.include?(row)
    end
  end

  def remove_col(col)
    rows = @cols.delete(col)
    -> { restore_col(col, rows) }
  end

  def restore_col(col, rows)
    @cols[col].merge(rows)
  end

  def remove_row(row)
    cols = @cols.each_with_object([]) do |(col, rows), cols|
      if rows.include?(row)
        rows.delete(row)
        cols << col
      end
    end
    -> { restore_row(row, cols) }
  end

  def restore_row(row, cols)
    cols.each { |col| @cols[col] << row }
  end

  def to_s
    buffer = String.new

    headers = cols.map { |col| '%4s' % col }.join(' ')
    buffer << headers << "\n"

    rows.each do |row|
      @cols.each do |_, present_rows|
        '%4s' % (present_rows.include?(row) ? 1 : 0)
      end
      line << ('%4s' % row)
      buffer << line.join(' ') << "\n"
    end

    buffer
  end
end
