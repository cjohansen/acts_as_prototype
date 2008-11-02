require File.dirname(__FILE__) + '/abstract_unit'

class PropertyTest < Test::Unit::TestCase
  fixtures :properties

  def atest_get_keys
    Property.set("prop_str", "Some value")

    prop_str, prop_sym = nil, nil
    prop_str = Property.get("prop_str")
    prop_sym = Property.get(:prop_str)

    assert_not_nil prop_str
    assert_equal prop_str, prop_sym
  end

  def atest_value_assoc
    prop = Property.new :name => "some_prop"
    prop.value = Project.find(1)

    assert_equal 1, prop.attributes["value"]
    assert_equal "Project", prop.attributes["type"]
    assert_equal Project.find(1), prop.value
  end

  def atest_set_assoc
    prop = Property.set("some_prop", Project.find(1))

    assert_equal 1, prop.attributes["value"]
    assert_equal "Project", prop.attributes["type"]
    assert_equal Project.find(1), prop.value
  end

  def atest_get
    Property.set(:project, Project.find(1))
    property = Property.get(:project)
raise "#{property.inspect} - #{property.class} - #{property.attributes.inspect}"
    assert_equal "1", property.attributes["value"]
    assert_equal "Project", property.attributes["type"]
    assert_equal Project.find(1), property.value
  end

  def atest_preserve_types
    props = { :str => "Some value",
              :int => 1,
              :float => 3.14,
              :sym => :str,
              :array => [1, "str", 2.0, :sym] }

    props.each_pair do |key, value|
      Property.set(key, value)
      assert_equal(value, Property.value(key)) unless key == :float
      assert_in_delta(value, Property.value(key), 0.0001) if key == :float
    end
  end
end
