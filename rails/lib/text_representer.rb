# frozen_string_literal: true

module TextRepresenter
  class UnmatchedPatternError < StandardError; end
  class FatalError < StandardError; end
  class MatchedException < StandardError; end
end

require_relative "text_representer/base"
require_relative "text_representer/renderer"
require_relative "text_representer/scanner"
