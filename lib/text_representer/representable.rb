# frozen_string_literal: true

module TextRepresenter
  module Representable
    def parse(string, exact: true)
      scanner = Scanner.new(string)
      apply(scanner)
      raise UnmatchedPatternError, "Expected end of string at position #{scanner.pos}" if exact && !scanner.eos?

      self
    end

    def render
      renderer = Renderer.new
      apply(renderer)
      renderer.result
    end

    # `#apply`can't be private because it's used by Scanner and Renderer, but it shouldn't be called directly by users.
    def apply(context)
      raise FatalError, "Already in context #{@representation_context}" if @representation_context

      begin
        @representation_context = context
        template
      ensure
        @representation_context = nil
      end
      self
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
      raise FatalError, "No context" unless @representation_context

      case type
      when :partial
        @representation_context.partial(self, ...)
      when :literal
        @representation_context.literal(self, ...)
      when :token
        @representation_context.token(self, ...)
      when :line
        @representation_context.line(self, ...)
      when :optional
        @representation_context.optional(self, ...)
      when :absence
        @representation_context.absence(self, ...)
      when :same_as
        @representation_context.same_as(self, ...)
      else
        raise FatalError, "Unknown expose type: #{type}"
      end
    end
  end
end
