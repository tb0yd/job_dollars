require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/reverse_merge'

module ActiveSupport
  class HashWithIndifferentAccess < Hash
    def extractable_options?
      true
    end

    def with_indifferent_access
      dup
    end

    def nested_under_indifferent_access
      self
    end

    def initialize(constructor = {})
      if constructor.respond_to?(:to_hash)
        super()
        update(constructor)
      else
        super(constructor)
      end
    end

    def default(key = nil)
      if key.is_a?(Symbol) && include?(key = key.to_s)
        self[key]
      else
        super
      end
    end

    def self.new_from_hash_copying_default(hash)
      hash = hash.to_hash
      new(hash).tap do |new_hash|
        new_hash.default = hash.default
        new_hash.default_proc = hash.default_proc if hash.default_proc
      end
    end

    def self.[](*args)
      new.merge!(Hash[*args])
    end

    alias_method :regular_writer, :[]= unless method_defined?(:regular_writer)
    alias_method :regular_update, :update unless method_defined?(:regular_update)

    def []=(key, value)
      regular_writer(convert_key(key), convert_value(value, for: :assignment))
    end

    alias_method :store, :[]=

    def update(other_hash)
      if other_hash.is_a? HashWithIndifferentAccess
        super(other_hash)
      else
        other_hash.to_hash.each_pair do |key, value|
          if block_given? && key?(key)
            value = yield(convert_key(key), self[key], value)
          end
          regular_writer(convert_key(key), convert_value(value))
        end
        self
      end
    end

    alias_method :merge!, :update

    def key?(key)
      super(convert_key(key))
    end

    alias_method :include?, :key?
    alias_method :has_key?, :key?
    alias_method :member?, :key?

    def fetch(key, *extras)
      super(convert_key(key), *extras)
    end

    def values_at(*indices)
      indices.collect { |key| self[convert_key(key)] }
    end

    def dup
      self.class.new(self).tap do |new_hash|
        set_defaults(new_hash)
      end
    end

    def merge(hash, &block)
      self.dup.update(hash, &block)
    end

    def reverse_merge(other_hash)
      super(self.class.new_from_hash_copying_default(other_hash))
    end

    def reverse_merge!(other_hash)
      replace(reverse_merge( other_hash ))
    end

    def replace(other_hash)
      super(self.class.new_from_hash_copying_default(other_hash))
    end

    def delete(key)
      super(convert_key(key))
    end

    def stringify_keys!; self end
    def deep_stringify_keys!; self end
    def stringify_keys; dup end
    def deep_stringify_keys; dup end
    undef :symbolize_keys!
    undef :deep_symbolize_keys!
    def symbolize_keys; to_hash.symbolize_keys! end
    def deep_symbolize_keys; to_hash.deep_symbolize_keys! end
    def to_options!; self end

    def select(*args, &block)
      dup.tap { |hash| hash.select!(*args, &block) }
    end

    def reject(*args, &block)
      dup.tap { |hash| hash.reject!(*args, &block) }
    end

    def to_hash
      _new_hash = Hash.new
      set_defaults(_new_hash)

      each do |key, value|
        _new_hash[key] = convert_value(value, for: :to_hash)
      end
      _new_hash
    end

    protected
      def convert_key(key)
        key.kind_of?(Symbol) ? key.to_s : key
      end

      def convert_value(value, options = {})
        if value.is_a? Hash
          if options[:for] == :to_hash
            value.to_hash
          else
            value.nested_under_indifferent_access
          end
        elsif value.is_a?(Array)
          if options[:for] != :assignment || value.frozen?
            value = value.dup
          end
          value.map! { |e| convert_value(e, options) }
        else
          value
        end
      end

      def set_defaults(target)
        if default_proc
          target.default_proc = default_proc.dup
        else
          target.default = default
        end
      end
  end
end
HashWithIndifferentAccess = ActiveSupport::HashWithIndifferentAccess
  
