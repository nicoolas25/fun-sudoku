class Entry
  attr_accessor :value, :left, :right

  def initialize(value, left, right)
    @value = value
    @left = left
    @right = right
    @removed = false
  end

  def remove
    return if @removed

    left.right = right
    right.left = left
    @removed = true
    true
  end

  def restore
    return unless @removed

    left.right = self
    right.left = self
    @removed = false
    true
  end

  def insert_after(entry)
    entry.left = self
    entry.right = right
    right.left = entry
    self.right = entry
  end
end
