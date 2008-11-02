#
# Generates the migrations necessary to use the acts_as_prototype plugin
#
class PrototypeMigrationMigrationGenerator < Rails::Generator::Base
  def manifest
    record do |m|
      m.migration_template 'migration.rb', 'db/migrate'
    end
  end

  def file_name
    "prototype_migration"
  end
end
