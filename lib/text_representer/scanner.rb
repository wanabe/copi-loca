# frozen_string_literal: true

require "strscan"
require "forwardable"

module TextRepresenter
  class Scanner
    extend Forwardable

    def initialize(string)
      @string_scanner = StringScanner.new(string)
    end

    def_delegators :@string_scanner, :eos?, :pos

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
        o.apply(self)
        yield o if block_given?
        assign(representer, name, o)
      when "+"
        arr = []
        loop do
          pos = @string_scanner.pos
          o = klass.new
          begin
            separator.call if separator && !arr.empty?
            o.apply(self)
            arr << o
          rescue UnmatchedPatternError
            @string_scanner.pos = pos
            break
          end
          yield o if block_given?
        end
        raise UnmatchedPatternError, "Expected at least one" if arr.empty?

        assign(representer, name, arr)
      else
        raise NotImplementedError, "Unsupported quantity: #{quantity}"
      end
    end

    def literal(representer, str)
      token(representer, nil, /#{Regexp.escape(str)}/)
    end

    def token(representer, name, regex, to: nil)
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
