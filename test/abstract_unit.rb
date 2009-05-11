#
# This file loads up the database needed to run the tests, and adds a few
# convenience methods.
#
# This file is originally by Jonathan Viney, written for the
# ActsAsTaggableOnSteroids plugin:
# http://svn.viney.net.nz/things/rails/plugins/acts_as_taggable_on_steroids/test/abstract_unit.rb
#
# Slightly modified for ActsAsPrototype by Christian Johansen
#
require 'test/unit'

begin
  require File.dirname(__FILE__) + '/../../../../config/environment'
rescue LoadError
  require 'rubygems'
  gem 'activerecord'
  gem 'actionpack'
  require 'active_record'
  require 'action_controller'
end

# Search for fixtures first
fixture_path = File.dirname(__FILE__) + '/fixtures/'
Dependencies.load_paths.insert(0, fixture_path)

require 'active_record/fixtures'

require File.dirname(__FILE__) + '/../lib/acts_as_prototype'

ActiveRecord::Base.logger = Logger.new(File.dirname(__FILE__) + '/debug.log')
ActiveRecord::Base.configurations = YAML::load(IO.read(File.dirname(__FILE__) + '/database.yml'))
ActiveRecord::Base.establish_connection(ENV['DB'] || 'mysql')

load(File.dirname(__FILE__) + '/schema.rb')

Test::Unit::TestCase.fixture_path = fixture_path

class Test::Unit::TestCase #:nodoc:
  self.use_transactional_fixtures = true
  self.use_instantiated_fixtures  = false

  def assert_queries(num = 1)
    $query_count = 0
    yield
  ensure
    assert_equal num, $query_count, "#{$query_count} instead of #{num} queries were executed."
  end

  def assert_no_queries(&block)
    assert_queries(0, &block)
  end
end

#
# Chains the execute method in order to add counting of SQL queries
#
ActiveRecord::Base.connection.class.class_eval do
  def execute_with_counting(sql, name = nil, &block)
    $query_count ||= 0
    $query_count += 1
    execute_without_counting(sql, name, &block)
  end

  alias_method_chain :execute, :counting
end
