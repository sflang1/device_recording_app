class DataStore
  def self.add(key, value)
    store = get()
    store[key] = value
    store
  end

  def self.get
    @@store_hash ||= {}
  end
end
