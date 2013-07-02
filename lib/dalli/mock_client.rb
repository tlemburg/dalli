module Dalli
  class MockClient
    def initialize(servers = nil, options = {})
      @options = options
      @data = {}
      @expiries = {}
    end

    def multi
      yield
    end

    def cas(key, ttl = nil, options = nil, &block)
      ttl ||= @options[:expires_in].to_i
      value = get(key)
      if !value.nil?
        newvalue = block.call(value)
        set(key, newvalue, ttl, options)
      end
    end

    def get_multi(*keys)
      values = {}
      options = keys.pop if keys.last.is_a?(Hash) || keys.last.nil?
      options ||= {}
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

    def incr(key, amt = 1, ttl = nil, default = nil)
      if !amt.respond_to? :to_i || amt < 0
        raise ArgumentError, "Positive values only: #{amt}"
      end
      ttl ||= @options[:expires_in].to_i
      value = get(key)
      unless value.nil? value.is_a? Integer && value > 0
        raise ArgumentError, "Key #{key} does not have a positive integer value"
      if value.nil?
        value = default
      else
        value += amt.to_i
      end
      set(key, value, ttl)
    end

    def decr(key, amt = 1, ttl = nil, default = nil)
      if !amt.respond_to? :to_i || amt < 0
        raise ArgumentError, "Positive values only: #{amt}"
      end
      ttl ||= @options[:expires_in].to_i
      value = get(key)
      unless value.nil? value.is_a? Integer && value > 0
        raise ArgumentError, "Key #{key} does not have a positive integer value"
      if value.nil?
        value = default
      else
        value -= amt.to_i
      end
      set(key, value, ttl)
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
