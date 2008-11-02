require File.dirname(__FILE__) + '/abstract_unit'

class PropertyTest < Test::Unit::TestCase
  def test_validations
    prop = Property.new

    assert !prop.valid?
    assert_not_nil prop.errors.on(:name)
  end

  def test_key
    prop = Property.set :prop, "My property"
    assert_equal :prop, prop.key
    assert_equal "prop", prop.name
  end

  def test_value_setter
    prop = Property.set :prop, 23
    assert_equal Marshal.dump(23), prop.attributes["value"]

    prop = Property.set :project, Project.find(1)
    assert_equal 1, prop.attributes["value"]
    assert_equal "Project", prop.attributes["assoc_type"]

    # Check return value too
    assert_equal "Value", prop.value=("Value")
  end

  def test_value_getter
    prop = Property.set :prop, "Some string"

    # First access should cause the value to be cached
    assert_equal "Some string", prop.value

    # Altering inner state should not be reflected when the value is cached
    prop.attributes["value"] = Marshal.dump("Some other string")
    assert_equal "Some string", prop.value

    # Setting the value should update the cache
    prop.value = "Some other string!"
    assert_equal "Some other string!", prop.value
  end

  def test_to_s
    prop = Property.set(:prop, 23.34)
    assert_equal "prop: 23.34", prop.to_s
  end

  def test_get_keys
    Property.set("prop_str", "Some value")

    prop_str, prop_sym = nil, nil
    prop_str = Property.get("prop_str")
    prop_sym = Property.get(:prop_str)

    assert_not_nil prop_str
    assert_equal prop_str, prop_sym
  end

  def test_value_assoc
    prop = Property.new(:name => "some_prop")
    prop.value = Project.find(1)

    assert_equal 1, prop.attributes["value"]
    assert_equal "Project", prop.attributes["assoc_type"]
    assert_equal Project.find(1), prop.value
  end

  def test_set_assoc
    prop = Property.set("some_prop", Project.find(1))

    assert_equal 1, prop.attributes["value"]
    assert_equal "Project", prop.attributes["assoc_type"]
    assert_equal Project.find(1), prop.value
  end

  def test_preserve_types
    props = { :str => "Some value",
              :int => 1,
              :float => 3.14,
              :sym => :str,
              :array => [1, "str", 2.0, :sym],
              :project => Project.find(1) }

    props.each_pair do |key, value|
      Property.set(key, value)
      assert_equal(value, Property.value(key)) unless key == :float
      assert_in_delta(value, Property.value(key), 0.0001) if key == :float
    end
  end
end
