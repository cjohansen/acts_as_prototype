require File.dirname(__FILE__) + '/abstract_unit'

class PropertyListTest < Test::Unit::TestCase
  def test_get
    prototype = Prototype.find(1)
    properties = PropertyList.new(prototype)
    prototype.set(:prop, "Value")


    assert_equal prototype.get(:prop), properties[:prop]
  end

  def test_set
    prototype = Prototype.find(1)
    properties = PropertyList.new(prototype)
    properties[:prop] = 32

    assert_equal 32, properties[:prop].value
    assert_equal properties[:prop].value, prototype.value(:prop)
  end
end
