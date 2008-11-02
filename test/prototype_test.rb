require File.dirname(__FILE__) + '/abstract_unit'

class PrototypeTest < Test::Unit::TestCase
  fixtures :accounts

  def test_get_property
    proto = Prototype.find(1)
    property = proto.properties.create(:name => "prop", :value => "My property")

    prop = proto.get_property("prop")
    assert_not_nil prop
    assert_equal "My property", prop.value
    assert_equal prop, proto.get_property(:prop)
    assert_equal prop, proto[:prop]
  end

  def test_prototype_chain
    acc1 = Prototype.find(1)
    acc2 = Prototype.find(2)

#    Property.set("prop1", 1)
#    acc1.properties.set("prop2", 2)
raise acc1.prototype.inspect
#    assert_equal 1, acc1[:prop1]
#    assert_equal 1, acc2[:prop1]
#    assert_equal 2, acc1[:prop2]
#    assert_equal 2, acc2[:prop2]

#    acc1[:prop1] = 34
#    assert_equal 1, Property.value(:prop1)
#    assert_equal 34, acc1[:prop1]
#    assert_equal 34, acc2[:prop1]

#    acc2[:prop1] = 68
#    assert_equal 1, Property.value(:prop1)
#    assert_equal 34, acc1[:prop1]
#    assert_equal 68, acc2[:prop1]
  end

  def test_set_property
    proto = Prototype.find(1)
    assert proto[:some] = "Prop"
  end
end
