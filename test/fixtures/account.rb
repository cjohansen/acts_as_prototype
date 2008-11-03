class Account < ActiveRecord::Base
  has_many :projects
  acts_as_prototype
end
