# frozen_string_literal: true
# rbs_inline: enabled

module TextRepresenter
  module Representable
    # @rbs @representation_context: TextRepresenter::Scanner | TextRepresenter::Context | nil

    # @rbs string: String
    # @rbs exact: bool
    # @rbs return: self
    def parse(string, exact: true)
      scanner = Scanner.new(string)
      apply(scanner)
      raise UnmatchedPatternError, "Remaining unmatched string: #{scanner.rest}" if exact && !scanner.eos?

      self
    end

    # @rbs return: String
    def render
      renderer = Renderer.new
      apply(renderer)
      renderer.result
    end

    # `#apply`can't be private because it's used by Scanner and Renderer, but it shouldn't be called directly by users.
    # @rbs context: TextRepresenter::Scanner | TextRepresenter::Context
    # @rbs return: self
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

    # @rbs name: Symbol
    # @rbs klass: Class
    # @rbs quantity: "+" | "*" | nil
    # @rbs separator: Proc?
    # @rbs &: ? (untyped) -> void
    # @rbs return: void
    def partial(name, klass, quantity: nil, separator: nil, &)
      expose(:partial, name, klass, quantity: quantity, separator: separator, &)
    end

    # @rbs str: String
    # @rbs return: void
    def literal(str)
      expose(:literal, str)
    end

    # @rbs name: Symbol?
    # @rbs regex: Regexp
    # @rbs to: Symbol?
    # @rbs from: Symbol?
    # @rbs return: void
    def token(name, regex, to: nil, from: nil)
      expose(:token, name, regex, to: to, from: from)
    end

    # @rbs &: (untyped) -> void
    # @rbs return: void
    def line(&)
      expose(:line, &)
    end

    # @rbs name: Symbol
    # @rbs &: ? (untyped) -> void
    # @rbs return: void
    def optional(name, &)
      expose(:optional, name, &)
    end

    # @rbs &: ? (untyped) -> void
    # @rbs return: void
    def absence(&)
      expose(:absence, &)
    end

    # @rbs name: Symbol
    # @rbs return: void
    def same_as(name)
      expose(:same_as, name)
    end

    private

    # @rbs type: Symbol
    # @rbs *args: untyped
    # @rbs **kwargs: untyped
    # @rbs &block: ? (untyped) -> void
    # @rbs return: void
    def expose(type, *args, **kwargs, &block)
      representation_context = @representation_context
      raise FatalError, "No context" unless representation_context

      case [type, args, block]
      in [:partial, [Symbol => name, Class => klass], Proc | nil]
        representation_context.partial(self, name, klass, quantity: kwargs[:quantity], separator: kwargs[:separator], &block)
      in [:literal, [String => str], nil]
        representation_context.literal(self, str)
      in [:token, [Symbol | nil => name, Regexp => regex], nil]
        representation_context.token(self, name, regex, to: kwargs[:to], from: kwargs[:from])
      in [:line, [], Proc]
        representation_context.line(self, &block)
      in [:optional, [Symbol => name], Proc]
        representation_context.optional(self, name, &block)
      in [:absence, [], Proc]
        representation_context.absence(self, &block)
      in [:same_as, [Symbol => name], nil]
        representation_context.same_as(self, name)
      else
        raise FatalError, "Unknown expose type: #{type.inspect} with args: #{args.map(&:class).inspect} and block: #{block ? 'given' : 'nil'}"
      end
    end

    # @rbs return: void
    def template
      # To be implemented by including class
      raise NotImplementedError, "Including class must implement #template method"
    end
  end
end
