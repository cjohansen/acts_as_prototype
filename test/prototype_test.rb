require File.dirname(__FILE__) + '/abstract_unit'

class PrototypeTest < Test::Unit::TestCase
  fixtures :accounts

  def teardown
    Property.delete_all
  end

  def test_get
    proto = Prototype.find(1)
    property = proto.properties.create(:name => "prop", :value => "My property")

    prop = proto.get("prop")
    assert_not_nil prop
    assert_equal "My property", prop.value
    assert_equal prop, proto.get(:prop)
  end

  def test_prototype_chain
    acc1 = Prototype.find(1)
    acc2 = Prototype.find(2)

    Property.set("prop1", 1)
    acc1.properties.set("prop2", 2)

    assert_equal 1, acc1.value(:prop1)
    assert_equal 1, acc2.value(:prop1)
    assert_equal 2, acc1.value(:prop2)
    assert_equal 2, acc2.value(:prop2)

    acc1.set(:prop1, 34)
    #acc2.flush_properties
    acc2 = Prototype.find(2)

    assert_equal 1, Property.value(:prop1)
    assert_equal 34, acc1.value(:prop1)
    assert_equal 34, acc2.value(:prop1)

    acc2.set(:prop1, 68)
    assert_equal 1, Property.value(:prop1)
    assert_equal 34, acc1.value(:prop1)
    assert_equal 68, acc2.value(:prop1)
  end

  def _test_cache_property
    proto = Prototype.find(3)
    proto.set :cached, "Value"

    assert_queries 1 do
      acc1.get :cached
      acc1.get :cached
      acc1.value :cached
      acc1.value :cached
    end
  end

  def test_set
    proto = Prototype.find(1)
    assert proto.set(:some, "Prop")
  end
end
