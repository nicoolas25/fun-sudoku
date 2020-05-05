# frozen_string_literal: true

require 'minitest/autorun'
require 'doubly_linked_list'

class DoublyLinkedListTest < Minitest::Test
  def test_instanciation_without_parameters
    assert DoublyLinkedList.new
  end

  def test_the_list_excludes_its_header
    list = DoublyLinkedList.new
    assert_equal 0, list.count
    assert_equal [], list.to_a
  end

  def test_enumerable_returns_entries_rather_than_values
    value = Object.new
    list = DoublyLinkedList.new << value
    assert_kind_of DoublyLinkedList::Entry, list.first
  end

  def test_accessing_the_last_element
    list = DoublyLinkedList.new << 1 << 2 << 3
    assert_equal 3, list.last.value
  end

  def test_adding_values_to_the_list
    value = Object.new
    list = DoublyLinkedList.new << value
    assert_same value, list.first.value
  end

  def test_adding_multiple_values
    list = DoublyLinkedList.new << 1 << 2 << 3
    assert_equal [1, 2, 3], list.each_values.to_a
  end

  def test_removing_and_restoring_value
    list = DoublyLinkedList.new << 1 << 2 << 3
    entry = list.find { |e| e.value == 2 }
    entry.remove
    assert_equal [1, 3], list.each_values.to_a

    entry.restore
    assert_equal [1, 2, 3], list.each_values.to_a
  end

  def test_removing_and_restoring_the_first_value
    list = DoublyLinkedList.new << 1 << 2 << 3
    entry = list.find { |e| e.value == 1 }
    entry.remove
    assert_equal [2, 3], list.each_values.to_a

    entry.restore
    assert_equal [1, 2, 3], list.each_values.to_a
  end

  def test_removing_and_restoring_the_last_value
    list = DoublyLinkedList.new << 1 << 2 << 3
    entry = list.find { |e| e.value == 3 }
    entry.remove
    assert_equal [1, 2], list.each_values.to_a
    assert entry.removed?

    entry.restore
    assert_equal [1, 2, 3], list.each_values.to_a
    refute entry.removed?
  end

  def test_removing_twice_does_not_mess_up_the_list
    list = DoublyLinkedList.new << 1 << 2 << 3
    entry = list.find { |e| e.value == 2 }
    entry.remove
    entry.remove
    assert_equal [1, 3], list.each_values.to_a
  end

  def test_restoring_twice_does_not_mess_up_the_list
    list = DoublyLinkedList.new << 1 << 2 << 3
    entry = list.find { |e| e.value == 2 }
    entry.remove
    entry.restore
    entry.restore
    assert_equal [1, 2, 3], list.each_values.to_a
  end
end
