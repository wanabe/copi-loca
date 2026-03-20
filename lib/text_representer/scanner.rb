# frozen_string_literal: true

require "strscan"
require "forwardable"

module TextRepresenter
  class Scanner
    extend Forwardable

    def initialize(string)
      @string_scanner = StringScanner.new(string)
    end

    def_delegators :@string_scanner, :eos?, :pos, :rest

    def assign(representer, name, value)
      representer.public_send("#{name}=", value)
    end

    def value(representer, name)
      representer.public_send(name)
    end

    def partial(representer, name, klass, quantity: nil, separator: nil)
      case quantity
      when nil
        o = klass.new
        yield(:before, o) if block_given?
        o.apply(self)
        yield(:after, o) if block_given?
        assign(representer, name, o)
      when "+", "*"
        arr = []
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
          yield o if block_given?
        end
        raise UnmatchedPatternError, "#{name}: Expected at least one" if arr.empty? && quantity == "+"

        assign(representer, name, arr)
      else
        raise NotImplementedError, "Unsupported quantity: #{quantity}"
      end
    end

    def literal(representer, str)
      token(representer, nil, /#{Regexp.escape(str)}/)
    end

    def token(representer, name, regex, to: nil)
      value = value(representer, name)&.to_s if name
      return same_as(representer, name) if value

      raise UnmatchedPatternError, "Expected token #{regex} at position #{@string_scanner.pos}" unless @string_scanner.scan(regex)

      value = @string_scanner.matched
      value = value.public_send(to) if to
      assign(representer, name, value) if name
    end

    def line(_representer)
      yield
      raise UnmatchedPatternError, "Expected end of line at position #{@string_scanner.pos}" unless @string_scanner.scan("\n")
      # do nothing, just consume the newline
    end

    def optional(representer, name)
      pos = @string_scanner.pos
      yield
      assign(representer, name, true)
    rescue UnmatchedPatternError
      @string_scanner.pos = pos
      assign(representer, name, false)
    end

    def absence(_representer)
      begin
        pos = @string_scanner.pos
        yield
      rescue UnmatchedPatternError
        @string_scanner.pos = pos
        return
      end
      raise UnmatchedPatternError, "Expected token to not match"
    end

    def same_as(representer, name)
      value = value(representer, name)
      raise UnmatchedPatternError, "Expected reference #{name} to be set" if value.nil?

      regex = /#{Regexp.escape(value.to_s)}/
      raise UnmatchedPatternError, "Expected token #{regex} at position #{@string_scanner.pos}" unless @string_scanner.scan(regex)
    end
  end
end
