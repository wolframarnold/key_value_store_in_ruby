class Store

  attr_reader :db, :value_counts

  def initialize(store_accessor)
    @store_accessor = store_accessor
    @db = {}
    @value_counts = {}
  end

  def has_key?(name)
    db.has_key?(name)
  end

  def [](name)
    db[name]
  end

  def numequalto(value)
    @value_counts[value] || 0
  end

  def set(name, value)
    # If key existed with another value, then we need to decrement the count on the previous value
    prev_value = @store_accessor.get(name)
    if !prev_value.nil?
      @value_counts[prev_value] ||= 0
      @value_counts[prev_value] -= 1
    end

    @db[name] = value
    @value_counts[value] ||= 0
    @value_counts[value] += 1
  end

  def unset(name)
    value = @store_accessor.get(name)
    @value_counts[value] ||= 0
    @value_counts[value] -= 1
    @db[name] = nil
  end

  def merge!(other_store)
    @db.merge!(other_store.db)
    @value_counts.merge!(other_store.value_counts) do |val, count, other_count|
      count + other_count
    end
  end

end