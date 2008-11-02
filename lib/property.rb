#
# A generic property. The property stores a single value which can be one of:
#
#   * Anything that can be serialized with Marshal::dump (stored as serialized
#     text)
#   * ActiveRecord objects. These are stored by reference (ie only the id) and
#     work as you'd expect a normal polymorphic has_one association to work.
#
# Properties that do not belong to a Prototype are "global" properties,
# accessible through both Propery class methods as well as any object that
# acts_as_prototype (ie has a prototype). Properties are resolved through a
# prototype chain much the same way they would be in Javascript and others.
#
# Examples:
#
#   # Create a new property
#   prop = Property.new :name => "send_confirmation", :value => true
#   prop.value #=> true
#   Property.value "send_confirmation" #=> true
#   Property.get("send_confirmation").value #=> true
#   Property.get("send_confirmation").to_s #=> "send_confirmation: true"
#
class Property < ActiveRecord::Base
  ### Attributes
  attr_protected :type

  ### Associations
  belongs_to :prototype

  ### Validation
  validates_presence_of :name, :value

  ### Instance methods

  #
  # Set a value. Serializes any value except ActiveRecord::Base decendants,
  # which are stored as references.
  #
  def value=(value)
    if value.kind_of? ActiveRecord::Base
      self[:value] = value.id
      self[:type] = value.class.to_s
    else
      self[:value] = Marshal::dump(value)
      self[:type] = nil
      @value = value
    end
  end

  #
  # Returns the value.
  #
  def value
    if @value.nil?
      if self[:type].nil?
        @value = Marshal::load(self[:value])
      else
        @value = self[:type].constantize.find(self[:value])
      end
    end

    return @value
  end

  #
  # Returns a string representation "name: value"
  #
  def to_s
    "#{name}: #{value}"
  end

  ### Class methods

  #
  # Find a property by name. The optional second argument is any object who
  # either 1) is a Prototype object, or 2) acts_as_prototype, ie responds to
  # the prototype method.
  #
  # "Climbs" the prototype chain looking for the property if an object is
  # specified.
  #
  # Raises an error if the property couldn't be found.
  #
  def self.get(prop, object = nil)
    context = self.context(object)
    property = context.find_by_name(prop)
    return property unless property.nil?

    # Climbin'
    if context.responds_to?(:prototype) && !context.prototype.nil?
      return self.get(prop, context.prototype)
    end

    raise ArgumentError.new("Property #{prop} not found")
  end

  #
  # Set a property value. If the optional object is not provided, this results
  # in either overriding the default value of a property, or creating a new
  # global property.
  #
  def self.set(prop, value, object = nil)
#    object = object.nil? ? self : object.prototype.properties
#    property = object.find_by_name(prop)
#    property ||= Property.new(:name => prop, :prototype => object)
#    property.value = value
#    property.save

#    value
  end

 private
  #
  # Accepts a generic object and returns any of the following (preferred
  # order):
  #
  #   1. The object itself if it is an istance of Prototype
  #   2. The prototype object if the object acts_as_prototype
  #   3. The Property class
  #
  # If the object is not a Prototype, and also does not act as prototype an error
  # is raised.
  #
  def self.context(object)
    return self if object.nil?
    return object if object.instance_of?(Prototype)
    return object.prototype if object.responds_to?(:prototype)
    raise ArgumentError.new("Object does not act like a prototype")
  end
end
