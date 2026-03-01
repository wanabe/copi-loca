# frozen_string_literal: true

module TextRepresenter
  class Renderer
    def initialize
      @output = +""
    end

    def result
      @output
    end

    # rubocop:disable Lint/UnusedMethodArgument
    def partial(representer, name, _klass, quantity: nil, parent: nil, index: nil)
      # rubocop:enable Lint/UnusedMethodArgument
      o = representer.attributes[name]
      if o.nil? && quantity == "?"
        nil
      elsif o.is_a?(Array)
        o.each { |e| e.apply(self) }
      elsif o.is_a?(Base)
        o.apply(self)
      else
        raise FatalError, "Expected #{name} to be a Base or an Array of Base, got #{o.class}"
      end
    end

    def literal(_representer, str)
      @output << str
    end

    # rubocop:disable Lint/UnusedMethodArgument
    def token(representer, name, _regex, to: nil)
      # rubocop:enable Lint/UnusedMethodArgument
      value = representer.attributes[name]
      @output << value.to_s
    end

    def line(_representer)
      yield
      @output << "\n"
    end

    def optional(representer, name)
      yield if representer.attributes[name]
    end

    def absence(_representer)
      # No output for absence
    end

    def same_as(representer, name)
      value = representer.attributes[name]
      @output << value.to_s
    end
  end
end
