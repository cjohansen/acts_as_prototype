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
  # Method is aliased as []
  #
  def get(prop)
    prop = prop.to_sym
    return @props[prop] unless @props.nil? || !@props.key?(prop)

    @props = {} if @props.nil?
    @props[prop] = self.properties.find_by_name(prop.to_s)

    if @props[prop].nil?
      if self.prototype.nil?
        @props[prop] = Property.get(prop)
      else
        @props[prop] = self.prototype.get(prop)
      end
    end

    raise ArgumentError.new("Property #{prop} does not exist") if @props[prop].nil?
    @props[prop]
  end

  #
  # Returns the value of a property
  #
  def value(prop)
    self.get(prop).value
  end

  #
  # Sets a property for this object. Method is aliased as []=
  #
  def set(prop, value)
    prop = prop.to_s
    property = self.properties.find_by_name(prop)
    property ||= Property.new(:name => prop, :prototype => self)
    property.value = value
    property.save
    @props = {} if @props.nil?
    @props[prop.to_sym] = property
  end

  #
  # Flushes property cache
  #
  def flush_properties
    @props = nil
  end
end
