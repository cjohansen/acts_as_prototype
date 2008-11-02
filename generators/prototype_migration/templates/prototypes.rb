class PrototypeMigration < ActiveRecord::Migration
  def self.up
    ### Prototypes
    create_table :prototypes do |t|
      t.references :prototype
      t.references :configurable, :polymorphic => true, :null => false
    end

    # One to one relationship
    add_index :prototypes, [:configurable_id, :configurable_type], :unique => true

    # Add foreign key if mysql_foreign_keys plugin is available
    add_foreign_key(:prototypes, :prototypes) if self.respond_to?(:add_foreign_key)

    ### Properties
    create_table :properties do |t|
      t.string :name, :null => false
      t.text :value, :null => false
      t.string :type
      t.references :prototype
    end

    # A property may only be set once for each object
    add_index :properties, [:name, :prototype_id], :unique => true

    # Add foreign key if mysql_foreign_keys plugin is available
    add_foreign_key(:properties, :prototypes) if self.respond_to?(:add_foreign_key)
  end

  def self.down
    drop_table :prototypes
    drop_table :properties
  end
end
