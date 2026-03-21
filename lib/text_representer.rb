# frozen_string_literal: true
# rbs_inline: enabled

module TextRepresenter
  # @rbs UnmatchedPatternError: Class
  class UnmatchedPatternError < StandardError; end
  # @rbs FatalError: Class
  class FatalError < StandardError; end
  # @rbs MatchedException: Class
  class MatchedException < StandardError; end
end

require_relative "text_representer/representable"
require_relative "text_representer/renderer"
require_relative "text_representer/scanner"
