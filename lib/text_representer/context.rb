# frozen_string_literal: true
# rbs_inline: enabled

module TextRepresenter
  class Context
    # :nocov:

    # @rbs representer: TextRepresenter::Representable
    # @rbs name: Symbol
    # @rbs klass: Class
    # @rbs quantity: "+" | "*" | nil
    # @rbs separator: Proc?
    # @rbs &: ? (Symbol, untyped) -> void
    # @rbs return: void
    def partial(representer, name, klass, quantity: nil, separator: nil, &)
      raise NotImplementedError, "Context#partial must be implemented by subclasses"
    end

    # @rbs representer: untyped # TODO: Specify type
    # @rbs str: String
    # @rbs return: void
    def literal(representer, str) = raise NotImplementedError, "Context#literal must be implemented by subclasses"

    # @rbs representer: untyped # TODO: Specify type
    # @rbs name: Symbol?
    # @rbs _regex: Regexp
    # @rbs to: Symbol?
    # @rbs from: Symbol?
    # @rbs return: void
    def token(representer, name, _regex, to: nil, from: nil) = raise NotImplementedError, "Context#token must be implemented by subclasses"

    # @rbs return: void
    def line = raise NotImplementedError, "Context#line must be implemented by subclasses"

    # @rbs representer: untyped # TODO: Specify type
    # @rbs name: Symbol
    # @rbs &: () -> void
    # @rbs return: void
    def optional(representer, name, &) = raise NotImplementedError, "Context#optional must be implemented by subclasses"

    # @rbs representer: untyped # TODO: Specify type
    # @rbs &: () -> void
    # @rbs return: void
    def absence(representer, &) = raise NotImplementedError, "Context#absence must be implemented by subclasses"

    # @rbs representer: untyped # TODO: Specify type
    # @rbs name: Symbol
    # @rbs return: void
    def same_as(representer, name) = raise NotImplementedError, "Context#same_as must be implemented by subclasses"

    # :nocov:
  end
end
