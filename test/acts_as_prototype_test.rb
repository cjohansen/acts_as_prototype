require File.dirname(__FILE__) + '/abstract_unit'

class ActsAsPrototypeTest < Test::Unit::TestCase
  fixtures :accounts, :prototypes, :projects

  def test_included
    account = accounts(:account1)
    assert account.kind_of?(ActsAsPrototype)
    assert account.respond_to?(:properties)
  end

  def test_get
    account = accounts(:account1)
    Property.set(:test_prop, "Yeah")
    assert_equal "Yeah", account.properties[:test_prop].value

    account.properties[:test_prop] = "Yeah right"
    assert_equal "Yeah right", account.properties[:test_prop].value
  end

  def test_beget
    account = accounts(:account1)
    account.properties[:prop] = "Yeah"
    Property.set(:global_prop, 32)

    new_account = account.beget(Account)
    assert_equal account.properties[:prop], new_account.properties[:prop]

    new_account.properties[:global_prop] = 98
    assert_equal 98, new_account.properties[:global_prop].value
    assert_equal 32, account.properties[:global_prop].value
  end
end
