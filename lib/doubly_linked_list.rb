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
    end

    def remove
      left.right = right
      right.left = left
    end

    def restore
      left.right = self
      right.left = self
    end

    def insert_after(value)
      Entry.new(value, self, right).tap do |new_entry|
        right.left = new_entry
        self.right = new_entry
      end
    end
  end
end

__END__

HEADER Cx ------> C1 C2 C3
HEADER Sy --> S1   0  1  0
              S2   1  1  0
              S3   1  0  1

Constraint to focus on: C1
  candidates sets to satisfy C1 are [S2, S3]
    candidate for solution: S2
      S2 satisfy [C1, C2]
        C1 is satified by either S3 or S2
        C2 is satified by either S1 or S2
        Thus S1, S2, and S3 must be removed
      C1 and C2 are satisfied thus removed
      This step can be summarized as:
        - S2 to solution
        - S1, S2, and S3 to remove
        - C1 and C2 to remove
      Resulting S are empty while there are still some C
        -> Backtracking
    candidate for solution: S3
      S3 satisfy [C1, C3]
        C1 is satified by either S2 or S3
        C3 is satified by S3 only
        Thus S2 and S3 must be removed
      C1 and C3 are satisfied thus removed
      This step can be summarized as:
        - S3 to solution
        - S2 and S3 to remove
        - C1 and C3 to remove
      There are still S1 and C2 in the matrix
        -> Restart the operation with the resulting matrix
Constraint to focus on: C2
  candidates sets to satisfy C2 are [S1]
    candidate for solution: S1
      S1 satisfy [C2]
        C2 is satified by S1 only
        Thus S1 must be removed
      C1 is satisfied thus removed
      This step can be summarized as:
        - S1 to solution
        - S1 to remove
        - C2 to remove
      Resulting matrix is empty
        -> Solution is [S3, S1]


C := All the ground the we wish to cover / Constraints
S := All available pieces to cover that ground / Sets

Each c, an entry from C, is composed of a reference to s, an entry from S.
The presence of c in C means that c.s covers c.

Each s, an entry from S, is composed of a reference to c, an entry from C.
The presence of s in S means that s.c is covered by s.

We need to be able to go from c, to all s such as s.c = c.
We need to be able to go from s, to all c such as c.s = s.

We need to be able to cover and uncover entries from C or S.

Q: The entry in C and S could eventually be the same?
