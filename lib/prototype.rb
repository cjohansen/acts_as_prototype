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
  def get_property(prop)
    prop = prop.to_sym
    return @props[prop] unless @props.nil? || !@props.key?(prop)

    @props = {} if @props.nil?
    @props[prop] = self.properties.find_by_name(prop.to_s)

    if @props[prop].nil?
      if self.prototype.nil?
        @props[prop] = Property.get(prop)
      else
        @props[prop] = self.prototype[prop]
      end
    end

    raise ArgumentError.new("Property does not exist") if @props[prop].nil?
    @props[prop]
  end

  alias_method :[], :get_property

  #
  # Sets a property for this object. Method is aliased as []=
  #
  def set_property(prop, value)
    prop = prop.to_s
    property = self.properties.find_by_name(prop)
    property ||= Property.new(:name => prop, :prototype => self)
    property.value = value
    property.save
    value
  end

  alias_method :[]=, :set_property
end
