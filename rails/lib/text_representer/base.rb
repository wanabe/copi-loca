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

    attr_reader :attributes, :context
    attr_accessor :parent

    def initialize(parent: nil, **initial_attributes)
      @attributes = initial_attributes
      @parent = parent
      @context = nil
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

    def apply(context)
      raise FatalError, "Already in context #{@context}" if @context

      begin
        @context = context
        template
      ensure
        @context = nil
      end
      self
    end

    def parse(string, exact: true)
      @scanner = Scanner.new(string)
      apply(@scanner)
      raise UnmatchedPatternError, "Expected end of string at position #{@scanner.pos}" if exact && !@scanner.eos?

      self
    end

    def to_s
      renderer = Renderer.new
      apply(renderer)
      renderer.result
    end

    # aliases
    def partial(...) = expose(:partial, ...)
    def literal(...) = expose(:literal, ...)
    def token(...) = expose(:token, ...)
    def line(...) = expose(:line, ...)
    def optional(...) = expose(:optional, ...)
    def absence(...) = expose(:absence, ...)
    def same_as(...) = expose(:same_as, ...)

    private

    def expose(type, ...)
      raise FatalError, "No context" unless @context

      case type
      when :partial
        @context.partial(self, ...)
      when :literal
        @context.literal(self, ...)
      when :token
        @context.token(self, ...)
      when :line
        @context.line(self, ...)
      when :optional
        @context.optional(self, ...)
      when :absence
        @context.absence(self, ...)
      when :same_as
        @context.same_as(self, ...)
      else
        raise FatalError, "Unknown expose type: #{type}"
      end
    end

    def template
      # :nocov:
      raise NotImplementedError, "Subclasses must implement template"
      # :nocov:
    end
  end
end
