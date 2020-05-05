class DoublyLinkedList
  include Enumerable

  def initialize(header_value: nil)
    @header = Entry.new(header_value, nil, nil).tap do |h|
      h.left = h
      h.right = h
    end
  end

  def <<(value)
    @header.left.insert_after(value)
    self
  end

  def last
    @header.left
  end

  def each
    cursor = @header.right
    while cursor != @header
      yield cursor
      cursor = cursor.right
    end
  end

  def each_values
    return to_enum(__method__) unless block_given?

    each { |entry| yield entry.value }
  end

  class Entry
    attr_accessor :value, :left, :right

    def initialize(value, left, right)
      @value = value
      @left = left
      @right = right
      @removed = false
    end

    def remove
      @removed = true
      left.right = right
      right.left = left
    end

    def restore
      @removed = false
      left.right = self
      right.left = self
    end

    def insert_after(value)
      Entry.new(value, self, right).tap do |new_entry|
        right.left = new_entry
        self.right = new_entry
      end
    end

    def removed?
      @removed
    end
  end
end

__END__

HEADER Cx ------> C1 C2 C3
HEADER Fy --> F1   0  1  0
              F2   1  1  0
              F3   1  0  1

Constraint to focus on: C1
  candidates sets to satisfy C1 are [F2, F3]
    candidate for solution: F2
      F2 satisfy [C1, C2]
        C1 is satified by either F3 or F2
        C2 is satified by either F1 or F2
        Thus F1, F2, and F3 must be removed
      C1 and C2 are satisfied thus removed
      This step can be summarized as:
        - F2 to solution
        - F1, F2, and F3 to remove
        - C1 and C2 to remove
      Resulting F are empty while there are still some C
        -> Backtracking
    candidate for solution: F3
      F3 satisfy [C1, C3]
        C1 is satified by either F2 or F3
        C3 is satified by F3 only
        Thus F2 and F3 must be removed
      C1 and C3 are satisfied thus removed
      This step can be summarized as:
        - F3 to solution
        - F2 and F3 to remove
        - C1 and C3 to remove
      There are still F1 and C2 in the matrix
        -> Restart the operation with the resulting matrix
Constraint to focus on: C2
  candidates sets to satisfy C2 are [F1]
    candidate for solution: F1
      F1 satisfy [C2]
        C2 is satified by F1 only
        Thus F1 must be removed
      C1 is satisfied thus removed
      This step can be summarized as:
        - F1 to solution
        - F1 to remove
        - C2 to remove
      Resulting matrix is empty
        -> Solution is [F3, F1]


C := All the ground the we wish to cover / Constraints
F := All available pieces to cover that ground / Facts

Each c, an entry from C, is composed of a reference to f, an entry from F.
The presence of c in C means that c.f covers c.

Each f, an entry from F, is composed of a reference to c, an entry from C.
The presence of f in F means that f.c is covered by f.

We need to be able to go from c, to all s such as f.c = c.
We need to be able to go from s, to all c such as c.f = f.

We need to be able to cover and uncover entries from C or F.

Q: The entry in C and F could eventually be the same?
