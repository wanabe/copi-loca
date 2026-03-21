# frozen_string_literal: true
# rbs_inline: enabled

require "strscan"
require "forwardable"

module TextRepresenter
  class Scanner < Context
    # @rbs @string_scanner: StringScanner

    extend Forwardable

    # @rbs string: String
    # @rbs return: void
    def initialize(string)
      super()
      @string_scanner = StringScanner.new(string)
    end

    # @rbs!
    #   def eos?: () -> bool
    #   def pos: () -> Integer
    #   def rest: () -> String

    def_delegators :@string_scanner, :eos?, :pos, :rest

    # @rbs representer: TextRepresenter::Representable
    # @rbs name: Symbol
    # @rbs value: untyped
    # @rbs return: void
    def assign(representer, name, value)
      representer.public_send("#{name}=", value)
    end

    # @rbs representer: TextRepresenter::Representable
    # @rbs name: Symbol
    # @rbs return: untyped
    def value(representer, name)
      representer.public_send(name)
    end

    # @rbs representer: TextRepresenter::Representable
    # @rbs name: Symbol
    # @rbs klass: Class
    # @rbs quantity: "+" | "*" | nil
    # @rbs separator: Proc?
    # @rbs &: ? (Symbol, untyped) -> void
    # @rbs return: void
    def partial(representer, name, klass, quantity: nil, separator: nil, &)
      case quantity
      when nil
        o = klass.new
        yield(:before, o) if block_given?
        o.apply(self)
        yield(:after, o) if block_given?
        assign(representer, name, o)
      when "+", "*"
        arr = [] #: Array[TextRepresenter::Representable]
        loop do
          pos = @string_scanner.pos
          o = klass.new
          begin
            separator.call if separator && !arr.empty?
            yield(:before, o) if block_given?
            o.apply(self)
            yield(:after, o) if block_given?
            arr << o
          rescue UnmatchedPatternError
            @string_scanner.pos = pos
            break
          end
        end
        raise UnmatchedPatternError, "#{name}: Expected at least one" if arr.empty? && quantity == "+"

        assign(representer, name, arr)
      else
        raise NotImplementedError, "Unsupported quantity: #{quantity}"
      end
    end

    # @rbs representer: TextRepresenter::Representable
    # @rbs str: String
    # @rbs return: void
    def literal(representer, str)
      token(representer, nil, /#{Regexp.escape(str)}/)
    end

    # @rbs representer: TextRepresenter::Representable
    # @rbs name: Symbol?
    # @rbs regex: Regexp
    # @rbs to: Symbol?
    # @rbs return: void
    def token(representer, name, regex, to: nil)
      if name
        value = value(representer, name)&.to_s
        return same_as(representer, name) if value
      end

      raise UnmatchedPatternError, "Expected token #{regex} at position #{@string_scanner.pos}" unless @string_scanner.scan(regex)

      value = @string_scanner.matched
      value = value.public_send(to) if to
      assign(representer, name, value) if name
    end

    # @rbs _representer: TextRepresenter::Representable
    # @rbs &: () -> void
    # @rbs return: void
    def line(_representer, &)
      yield
      raise UnmatchedPatternError, "Expected end of line at position #{@string_scanner.pos}" unless @string_scanner.scan("\n")
      # do nothing, just consume the newline
    end

    # @rbs representer: TextRepresenter::Representable
    # @rbs name: Symbol
    # @rbs &: ? () -> void
    # @rbs return: void
    def optional(representer, name, &)
      pos = @string_scanner.pos
      begin
        yield
        assign(representer, name, true)
      rescue UnmatchedPatternError
        @string_scanner.pos = pos
        assign(representer, name, false)
      end
    end

    # @rbs _representer: TextRepresenter::Representable
    # @rbs &: ? () -> void
    # @rbs return: void
    def absence(_representer, &)
      pos = @string_scanner.pos
      begin
        yield
      rescue UnmatchedPatternError
        @string_scanner.pos = pos
        return
      end
      raise UnmatchedPatternError, "Expected token to not match"
    end

    # @rbs representer: TextRepresenter::Representable
    # @rbs name: Symbol
    # @rbs return: void
    def same_as(representer, name)
      value = value(representer, name)
      raise UnmatchedPatternError, "Expected reference #{name} to be set" if value.nil?

      regex = /#{Regexp.escape(value.to_s)}/
      raise UnmatchedPatternError, "Expected token #{regex} at position #{@string_scanner.pos}" unless @string_scanner.scan(regex)
    end
  end
end
