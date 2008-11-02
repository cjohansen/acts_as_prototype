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
  attr_protected :assoc_type

  ### Associations
  belongs_to :prototype

  ### Validation
  validates_presence_of :name

  ### Instance methods

  #
  # Returns the name as a symbol
  #
  def key
    name.to_sym
  end

  #
  # Set a value. Serializes any value except ActiveRecord::Base decendants,
  # which are stored as references.
  #
  def value=(value)
    if value.kind_of? ActiveRecord::Base
      self[:value] = value.id
      self[:assoc_type] = value.class.to_s
    else
      self[:value] = Marshal::dump(value)
      self[:assoc_type] = nil
    end

    @value = value
  end

  #
  # Returns the value.
  #
  def value
    if @value.nil?
      if self[:assoc_type].nil?
        @value = Marshal::load(self[:value])
      else
        @value = self[:assoc_type].constantize.find(self[:value])
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
  # Find a property by name.
  #
  def self.get(property)
    self.find_by_name(property.to_s, :conditions => ["prototype_id is null"])
  end

  #
  # Set the value of a property, or create a new global property
  #
  def self.set(property, value)
    property = self.get(property) || Property.new(:name => property.to_s)
    property.value = value
    property.save
    property
  end

  #
  # Finds a property with Property.get and returns its value
  #
  def self.value(property)
    property = self.get(property)
    property.nil? ? nil : property.value
  end
end
