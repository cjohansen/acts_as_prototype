#
# A configurable ActiveRecord resource. The module is included in
# ActiveRecord::Base, thus enabling all active record models to do
# +acts_as_prototype+ which enables the following instance methods:
#
#   properties
#   prototype
#   beget
#
# In other words, making an ActiveRecord class "act as prototype" means you can
# annotate it with arbitrary properties, set up configuration cascades and
# generate new objects that "inherits" all properties from other objects.
#
module ActsAsPrototype
  #
  # Called when module is included
  #
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def acts_as_prototype
      include ActsAsPrototype::InstanceMethods
      has_one :prototype, :as => :configurable
    end
  end

  module InstanceMethods
    #
    # Creates a new (unsaved) object that "inherits" the properties of this
    # object. Note that the model objects need not share anything; it's only the
    # properties that are transferred.
    #
    # The method accepts a two parameters: the first should be the class for the
    # new object (default is same as this object) and the second is a hash of
    # attributes for the new object.
    #
    # Function name is borrowed from Douglas Crockfords Object.beget for
    # JavaScript.
    #
    def beget(type = self.class, attributes = {})
      object = type.new(attributes)
      object.prototype = Prototype.new(:prototype => self.prototype)
      object
    end

    #
    # Adds the prototype object when a new object is created
    #
    def initialize
      super

      if self.prototype.nil?
        self.prototype = Prototype.new(:configurable => self)
        self.prototype.save
      end
    end

    #
    # Returns a property list
    #
    def properties
      @properties = PropertyList.new(self.prototype) if @properties.nil?
      @properties
    end
  end
end

ActiveRecord::Base.send(:include, ActsAsPrototype)
