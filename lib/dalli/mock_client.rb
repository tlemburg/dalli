module Dalli
  class MockClient
    def initialize(servers = nil, options = {})
      @options = options
      @data = {}
      @expiries = {}
    end

    def get(key, options = nil)
      if @expiries[key].nil? || @expiries[key] > Time.now.to_i
        return @data[key]
      else
        delete(key)
        return nil
      end
    end

    def set(key, value, ttl = nil, options = nil)
      ttl ||= @options[:expires_in].to_i
      @data[key] = value
      @expiries[key] = Time.now.to_i + ttl if ttl != 0
      true
    end

    def delete(key)
      @data.delete(key)
      @expiries.delete(key)
    end
  end
end
