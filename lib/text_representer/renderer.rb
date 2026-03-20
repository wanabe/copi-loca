# frozen_string_literal: true

module TextRepresenter
  class Renderer
    def initialize
      @output = +""
    end

    def result
      @output
    end

    def value(representer, name)
      representer.public_send(name)
    end

    def partial(representer, name, _klass, quantity: nil, separator: nil)
      o = value(representer, name)
      if o.is_a?(Array) && %w[+ *].include?(quantity)
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

    def literal(_representer, str)
      @output << str
    end

    def token(representer, name, _regex, to: nil)
      raise "Unexpected to: #{to}" if to && !to.is_a?(Symbol)

      value = value(representer, name)
      @output << value.to_s
    end

    def line(_representer)
      yield
      @output << "\n"
    end

    def optional(representer, name)
      yield if value(representer, name)
    end

    def absence(_representer)
      # No output for absence
    end

    def same_as(representer, name)
      value = value(representer, name)
      @output << value.to_s
    end
  end
end
