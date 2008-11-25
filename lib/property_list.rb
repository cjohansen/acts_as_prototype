#
# Wraps a prototype object and provides some syntactical sugar.
#
# Example:
#   properties = PropertyList.new(Prototype.find(1))
#   properties[:some_prop] #=> Same as Prototype#get
#   properties[:some_prop] = "Some value" #=> Same as Prototype#set
#
class PropertyList

  #
  # Initialize a new property list object for the given prototype
  #
  def initialize(prototype)
    @prototype = prototype
  end

  #
  # Get a property
  #
  def [](prop)
    @prototype.get(prop)
  end

  #
  # Set the value of a property
  #
  def []=(prop, value)
    @prototype.set(prop, value)
  end
end
