require File.dirname(__FILE__) + '/abstract_unit'

class ActsAsPrototypeTest < Test::Unit::TestCase
  fixtures :accounts, :prototypes, :projects

  def test_working
    assert_equal "Acme", Account.find(1).name
  end
end
