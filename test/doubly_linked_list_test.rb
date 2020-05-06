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

  def test_appending_an_element
    value = Object.new
    list = DoublyLinkedList.new
    entry = list.append(value)
    assert_kind_of DoublyLinkedList::Entry, entry
    assert_same value, entry.value
  end

  def test_enumerable_returns_entries_rather_than_values
    value = Object.new
    list = build(value)
    assert_kind_of DoublyLinkedList::Entry, list.first
  end

  def test_adding_values_to_the_list
    value = Object.new
    list = build(value)
    assert_same value, list.first.value
  end

  def test_adding_multiple_values
    list = build(1, 2, 3)
    assert_equal [1, 2, 3], values(list)
  end

  def test_removing_and_restoring_value
    list = build(1, 2, 3)
    entry = list.find { |e| e.value == 2 }
    entry.remove
    assert_equal [1, 3], values(list)

    entry.restore
    assert_equal [1, 2, 3], values(list)
  end

  def test_removing_and_restoring_the_first_value
    list = build(1, 2, 3)
    entry = list.find { |e| e.value == 1 }
    entry.remove
    assert_equal [2, 3], values(list)

    entry.restore
    assert_equal [1, 2, 3], values(list)
  end

  def test_removing_and_restoring_the_last_value
    list = build(1, 2, 3)
    entry = list.find { |e| e.value == 3 }
    entry.remove
    assert_equal [1, 2], values(list)

    entry.restore
    assert_equal [1, 2, 3], values(list)
  end

  def test_removing_twice_does_not_mess_up_the_list
    list = build(1, 2, 3)
    entry = list.find { |e| e.value == 2 }
    entry.remove
    entry.remove
    assert_equal [1, 3], values(list)
  end

  def test_restoring_twice_does_not_mess_up_the_list
    list = build(1, 2, 3)
    entry = list.find { |e| e.value == 2 }
    entry.remove
    entry.restore
    entry.restore
    assert_equal [1, 2, 3], values(list)
  end

  # TODO: Test the on_remove and on_restore callbacks

  private

  def values(list)
    list.map(&:value)
  end

  def build(*values)
    DoublyLinkedList.new.tap do |list|
      values.each { |value| list.append(value) }
    end
  end
end
