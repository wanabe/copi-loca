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
    def nested(representer, name, _klass, quantity: nil, parent: nil, index: nil)
      # rubocop:enable Lint/UnusedMethodArgument
      o = representer.attributes[name]
      if o.nil? && quantity == "?"
        nil
      elsif o.is_a?(Array)
        o.each { |e| e.run(self) }
      elsif o.is_a?(Base)
        o.run(self)
      else
        raise FatalError, "Expected #{name} to be a Base or an Array of Base, got #{o.class}"
      end
    end

    def fixed(_representer, str)
      @output << str
    end

    # rubocop:disable Lint/UnusedMethodArgument
    def pattern(representer, name, _regex, to: nil)
      # rubocop:enable Lint/UnusedMethodArgument
      value = representer.attributes[name]
      @output << value.to_s
    end

    def line(_representer)
      yield
      @output << "\n"
    end

    def quantity(representer, name, quantity)
      case quantity
      when "?"
        yield if representer.attributes[name]
      else
        raise NotImplementedError, "Unsupported quantity: #{quantity}"
      end
    end

    def denied(_representer)
      # No output for denied patterns
    end

    def ref(representer, name)
      value = representer.attributes[name]
      @output << value.to_s
    end
  end
end
