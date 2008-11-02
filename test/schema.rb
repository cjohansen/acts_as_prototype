#
# Schema needed to test acts_as_prototype
#
ActiveRecord::Schema.define :version => 0 do
  create_table :prototypes, :force => true do |t|
    t.references :prototype
    t.references :configurable, :polymorphic => true, :null => false
  end

  # One to one relationship
  add_index :prototypes, [:configurable_id, :configurable_type], :unique => true

  create_table :properties, :force => true do |t|
    t.string :name, :null => false
    t.text :value, :null => false
    t.string :type
    t.references :prototype
  end

  # A property may only be set once for each object
  add_index :properties, [:name, :prototype_id], :unique => true

  create_table :accounts, :force => true do |t|
    t.string :name
  end

  create_table :projects, :force => true do |t|
    t.string :name
    t.references :account
  end
end
