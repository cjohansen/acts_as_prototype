#
# A prototype object.
#
class Prototype < ActiveRecord::Base
  ### Associations
  belongs_to :configurable, :polymorphic => true
  belongs_to :prototype
  has_many :properties

  ### Instance methods

  #
  # Find property for this object. If the property is not found, the prototype
  # is checked. If no property is found on the prototype chain either, an error
  # is raised.
  #
  def get(prop)
    prop = prop.to_sym
    property = self.properties.find_by_name(prop.to_s)

    if property.nil?
      if self.prototype.nil?
        property = Property.get(prop)
      else
        property = self.prototype.get(prop)
      end
    end

    raise ArgumentError.new("Property #{prop} does not exist") if property.nil?
    property
  end

  #
  # Returns the value of a property
  #
  def value(prop)
    self.get(prop).value
  end

  #
  # Sets a property for this object.
  #
  def set(prop, value)
    prop = prop.to_s
    property = @props[prop.to_sym] unless @props.nil? || !@props.key?(prop.to_sym)
    property ||= self.properties.find_by_name(prop)
    property ||= Property.new(:name => prop, :prototype => self)
    property.value = value
    property.save

    # Cache value
    cache_property(property)
  end

  #
  # Flushes property cache
  #
  def flush_properties
    @props = nil
  end

 private
  #
  # Look for property in cache before retrieving from database. If property is
  # retrieved from database it is cached.
  #
  def get_with_caching(prop)
    return @props[prop.to_sym] unless @props.nil? || !@props.key?(prop.to_sym)
    cache_property(get_without_caching(prop))
  end

  # Add caching to get method
  #alias_method_chain :get, :caching

  #
  # Stores a property in internal cache
  #
  def cache_property(property)
    @props = {} if @props.nil?
    @props[property.key] = property
  end
end
