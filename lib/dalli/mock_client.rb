module Dalli
  class MockClient
    def initialize(servers = nil, options = {})
      @options = options
      @data = {}
      @expiries = {}
    end

    def get_multi(*keys)
      values = {}
      options = keys.pop if keys.last.is_a?(Hash) || keys.last.nil?
      keys.each do |key|
        values[key] = get(key, options)
      end
      values
    end

    def get(key, options = nil)
      if @expiries[key].nil? || @expiries[key] > Time.now.to_i
        return @data[key]
      else
        delete(key)
        return nil
      end
    end

    def flush(delay = 0)
      @data.delete_all
      @expiries.delete_all
    end

    alias_method :flush_all, :flush

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

    def touch(key, ttl = nil)
      ttl ||= @options[:expires_in].to_i
      if !ttl.nil? && ttl > 0 && !@data[key].nil?
        @expiries[key] = (Time.now + ttl).to_i
        true
      else
        nil
      end
    end

  end
end
