# frozen_string_literal: true

module TextRepresenter
  class Base
    class << self
      def attribute(name)
        define_method(name) do
          @attributes[name]
        end
        define_method("#{name}=") do |value|
          @attributes[name] = value
        end
      end

      def parent(name)
        define_method(name) do
          @parent
        end
        define_method("#{name}=") do |value|
          @parent = value
        end
      end
    end

    attr_reader :attributes, :runner
    attr_accessor :parent

    def initialize(parent: nil, **initial_attributes)
      @attributes = initial_attributes
      @parent = parent
      @runner = nil
    end

    def [](key)
      @attributes[key.to_sym]
    end

    def dig(key, *rest)
      return self[key] if rest.empty?

      self[key]&.dig(*rest)
    end

    def as_json
      @attributes.to_h do |k, v|
        name = k.to_s
        if v.is_a?(Base)
          [name, v.as_json]
        elsif v.is_a?(Array) && v.all?(Base)
          [name, v.map(&:as_json)]
        else
          [name, v]
        end
      end
    end

    def run(runner)
      raise FatalError, "Already running #{@runner}" if @runner

      begin
        @runner = runner
        represent
      ensure
        @runner = nil
      end
      self
    end

    def parse(string, exact: true)
      @scanner = Scanner.new(string)
      run(@scanner)
      raise UnmatchedPatternError, "Expected end of string at position #{@scanner.pos}" if exact && !@scanner.eos?

      self
    end

    def to_s
      renderer = Renderer.new
      run(renderer)
      renderer.result
    end

    private

    def define(type, ...)
      raise FatalError, "No runner" unless @runner

      case type
      when :nested
        @runner.nested(self, ...)
      when :fixed
        @runner.fixed(self, ...)
      when :pattern
        @runner.pattern(self, ...)
      when :line
        @runner.line(self, ...)
      when :quantity
        @runner.quantity(self, ...)
      when :denied
        @runner.denied(self, ...)
      when :ref
        @runner.ref(self, ...)
      else
        raise FatalError, "Unknown define type: #{type}"
      end
    end

    def represent
      # :nocov:
      raise NotImplementedError, "Subclasses must implement represent"
      # :nocov:
    end
  end
end
