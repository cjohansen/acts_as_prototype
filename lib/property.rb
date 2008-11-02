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
      self[:type] = value.class.to_s
    else
      self[:value] = Marshal::dump(value)
      self[:type] = nil
    end

    @value = value
  end

  #
  # Returns the value.
  #
  def value
    puts "\n\n#{self[:value]} - #{self[:type]} (#{@value})\n\n"
    if @value.nil?
      if self[:type].nil?
        @value = Marshal::load(self[:value])
      else
        @value = self[:type].constantize.find(self[:value])
      end
    end
puts "#{@value}\n\n"
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
#  def self.get(prop, object = nil)
    # Check cache
#    cached = self.property_cache(prop, object)
#    return cached unless cached.nil?

#    context = self.context(object)
#    property = context.find_by_name(prop.to_s)
#    return self.cache(property) unless property.nil?

    # Climbin'
#    if context.respond_to?(:prototype) && !context.prototype.nil?
#      return self.cache(self.get(prop, context.prototype))
#    end

#    raise ArgumentError.new("Property #{prop} not found")
#  end

  #
  # Finds a property with Property.get and returns its value
  #
#  def self.value(prop, object = nil)
#    self.get(prop, object).value
#  end

  #
  # Set a property value. If the optional object is not provided, this results
  # in either overriding the default value of a property, or creating a new
  # global property.
  #
#  def self.set(prop, value, object = nil)
#    prototype = nil

#    if object.nil?
#      conditions = ["prototype_id is null"]
#    else
#      conditions = ["prototype_id = ?", object.id]
#      prototype = object.prototype
#    end

#    property = Property.find_by_name(prop.to_s, :conditions => conditions)
#    property ||= Property.new(:name => prop.to_s, :prototype => prototype)
#    property.value = value
#    property.save

#    value
#  end

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
#  def self.context(object)
#    return self if object.nil?
#    return object if object.instance_of?(Prototype)
#    return object.prototype if object.responds_to?(:prototype)
#    raise ArgumentError.new("Object does not act like a prototype")
#  end

  #
  # Looks up property in internal cache. If caching is disabled this method
  # always returns nil.
  #
#  def self.property_cache(prop, object = nil)
#    return nil unless @@cache_properties

#    key = self.cache_key(object)
#    return nil unless @@properties.key?(key)

#    return @@properties[key][prop.to_sym]
#  end

  #
  # Caches a property
  #
#  def self.cache(property)
#    key = self.cache_key(property.prototype)
#    @@properties[key] = {} unless @@properties.key?(key)
#    @@properties[key][property.key] = property
#    property
#  end

  #
  # Generates a cache key for any given object. If the object is nil then the
  # key is :default
  #
#  def self.cache_key(object)
#    object.nil? ? :default : (object.class.to_s + object.id.to_s).to_sym
#  end
end
