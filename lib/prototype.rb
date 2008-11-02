#
# A prototype object.
#
class Prototype < ActiveRecord::Base
  ### Associations
  belongs_to :configurable, :polymorphic => true
  belongs_to :prototype
  has_many :properties

  ### Validations
end
