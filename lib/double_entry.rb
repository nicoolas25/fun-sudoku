# frozen_string_literal: true

require 'entry'

class DoubleEntry
  attr_reader :v_entry, :h_entry

  def initialize(vertical:, horizontal:)
    @v_entry = NestedEntry.new(self, vertical)
    @h_entry = NestedEntry.new(self, horizontal)
  end

  def remove
    @h_entry.do_remove
    @v_entry.do_remove
  end

  def restore
    @v_entry.do_restore
    @h_entry.do_restore
  end

  def insert_after(_)
    raise NotImplementedError
  end

  NestedEntry = Class.new(Entry) do
    def initialize(parent, value)
      super(value, nil, nil)
      @parent = parent
    end

    alias_method :do_remove, :remove

    def remove
      @parent.remove
    end

    alias_method :do_restore, :restore

    def restore
      @parent.restore
    end
  end
end
