# frozen_string_literal: true

require "strscan"

module TextRepresenter
  class Scanner
    def initialize(string)
      @string_scanner = StringScanner.new(string)
    end

    delegate :eos?, to: :@string_scanner

    delegate :pos, to: :@string_scanner

    def partial(representer, name, klass, quantity: nil, parent: nil, index: nil)
      case quantity
      when nil
        o = klass.new
        o.apply(self)
        o.parent = representer if parent
        representer.attributes[name] = o
      when "?"
        pos = @string_scanner.pos
        o = klass.new
        begin
          o.apply(self)
        rescue UnmatchedPatternError
          o = nil
          @string_scanner.pos = pos
        end
        representer.attributes[name] = o
      when "+"
        arr = []
        loop do
          pos = @string_scanner.pos
          o = klass.new
          begin
            o.apply(self)
            o.parent = representer if parent
            o.attributes[index] = arr.size if index
            arr << o
          rescue UnmatchedPatternError
            @string_scanner.pos = pos
            break
          end
        end
        raise UnmatchedPatternError, "Expected at least one" if arr.empty?

        representer.attributes[name] = arr
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
      representer.attributes[name] = value if name
    end

    def line(_representer)
      yield
      raise UnmatchedPatternError, "Expected end of line at position #{@string_scanner.pos}" unless @string_scanner.scan("\n")
      # do nothing, just consume the newline
    end

    def optional(representer, name)
      pos = @string_scanner.pos
      yield
      representer.attributes[name] = true
    rescue UnmatchedPatternError
      @string_scanner.pos = pos
      representer.attributes[name] = false
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
      value = representer.attributes[name]
      raise UnmatchedPatternError, "Expected reference #{name} to be set" if value.nil?

      regex = /#{Regexp.escape(value.to_s)}/
      raise UnmatchedPatternError, "Expected token #{regex} at position #{@string_scanner.pos}" unless @string_scanner.scan(regex)
    end
  end
end
