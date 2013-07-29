require 'forwardable'
require File.expand_path('../store_accessor', __FILE__)

class Command

  extend Forwardable
  def_delegators :@store_accessor, :begin_tx, :commit, :rollback, :get, :numequalto

  attr_reader :store_accessor

  def initialize(store_accessor)
    @store_accessor = store_accessor
  end

  def set(name, value)
    store_accessor.current_tx.set(name, value)
  end

  def unset(name)
    store_accessor.current_tx.unset(name)
  end

  def method_missing(method)
    "NO SUCH COMMAND"
  end

end