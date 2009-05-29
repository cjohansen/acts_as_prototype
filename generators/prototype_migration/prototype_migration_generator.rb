#
# Generates the migrations necessary to use the acts_as_prototype plugin
#
class PrototypeMigrationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'prototypes.rb', 'db/migrate'
    end
  end

  def file_name
    "prototype_migration"
  end
end
