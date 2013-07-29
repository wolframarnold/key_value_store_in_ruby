require File.expand_path('../store', __FILE__)

class StoreAccessor

  def initialize
    @root_store = Store.new(self)
    @open_txx = []
  end

  # API for tests only, client code should use the 'get' method
  # API for tests only, client code should use the 'get' method
  def [](name)
    @root_store[name]
  end

  def get(name)
    found = false
    value = @open_txx.reverse_each do |tx|
      if tx.has_key?(name)
        found = true
        break tx[name]
      end
    end
    found ? value : @root_store[name]
  end

  def numequalto(value)
    @root_store.numequalto(value) +
    @open_txx.reduce(0) do |sum, tx|
      sum += tx.numequalto(value)
    end
  end

  def current_tx
    @open_txx.last || @root_store
  end

  def begin_tx
    @open_txx.push(Store.new(self))
  end

  def commit
    return 'NO TRANSACTION' if @open_txx.empty?
    @open_txx.each do |tx|
      @root_store.merge!(tx)
    end
    @open_txx.clear
    'OK'
  end

  def rollback
    @open_txx.pop.nil? ? 'NO TRANSACTION' : 'OK'
  end

end