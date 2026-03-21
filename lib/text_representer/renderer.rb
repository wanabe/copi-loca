# frozen_string_literal: true
# rbs_inline: enabled

module TextRepresenter
  class Renderer < Context
    # @rbs @output: String

    # @rbs return: void
    def initialize
      super
      @output = +""
    end

    # @rbs return: String
    def result
      @output
    end

    # @rbs representer: TextRepresenter::Representable
    # @rbs name: Symbol
    # @rbs return: untyped
    def value(representer, name)
      representer.public_send(name)
    end

    # @rbs representer: TextRepresenter::Representable
    # @rbs name: Symbol
    # @rbs _klass: Class
    # @rbs quantity: "+" | "*" | nil
    # @rbs separator: Proc?
    # @rbs &: (Symbol, untyped) -> void
    # @rbs return: void
    def partial(representer, name, _klass, quantity: nil, separator: nil, &)
      o = value(representer, name)
      if o.is_a?(Array) && quantity && %w[+ *].include?(quantity)
        rest = false
        o.each do |e|
          separator.call if rest && separator
          e.apply(self)
          rest = true
        end
      elsif o.is_a?(Representable)
        o.apply(self)
      else
        raise FatalError, "Expected #{name} to be a Representable or an Array of Representable, got #{o.class}"
      end
    end

    # @rbs _representer: TextRepresenter::Representable
    # @rbs str: String
    # @rbs return: void
    def literal(_representer, str)
      @output << str
    end

    # @rbs representer: TextRepresenter::Representable
    # @rbs name: Symbol?
    # @rbs _regex: Regexp
    # @rbs to: Symbol?
    # @rbs return: void
    def token(representer, name, _regex, to: nil)
      raise "Unexpected to: #{to}" if to && !to.is_a?(Symbol)
      raise "Need name for token" unless name

      value = value(representer, name)
      @output << value.to_s
    end

    # @rbs _representer: TextRepresenter::Representable
    # @rbs &: () -> void
    # @rbs return: void
    def line(_representer, &)
      yield
      @output << "\n"
    end

    # @rbs representer: TextRepresenter::Representable
    # @rbs name: Symbol
    # @rbs &: () -> void
    # @rbs return: void
    def optional(representer, name, &)
      yield if value(representer, name)
    end

    # @rbs _representer: TextRepresenter::Representable
    # @rbs return: void
    def absence(_representer)
      # No output for absence
    end

    # @rbs representer: TextRepresenter::Representable
    # @rbs name: Symbol
    # @rbs return: void
    def same_as(representer, name)
      value = value(representer, name)
      @output << value.to_s
    end
  end
end
