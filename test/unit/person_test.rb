require File.dirname(__FILE__) + '/../test_helper'

class PersonTest < Test::Unit::TestCase
  def test_accessors
    p = Person.new
    p.firstname = 'Frank'
    p.lastname = 'Duckart'
    p.uhuuid = '17958670'
    p.uid = 'duckart'
    p.email = 'duckart@computer.org'
    
    assert_equal 'duckart', p.uid
    assert_equal '17958670', p.uhuuid
    assert_equal 'Duckart', p.lastname
    assert_equal 'Frank', p.firstname
  end
end