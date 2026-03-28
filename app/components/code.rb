# frozen_string_literal: true
# rbs_inline: enabled

class Components::Code < Components::Base
  # @rbs @code: String
  # @rbs @path: String?
  # @rbs @language: Symbol?

  # @rbs code: String
  # @rbs path: String?
  # @rbs language: Symbol?
  # @rbs return: void
  def initialize(code:, path: nil, language: nil)
    @code = code
    @path = path

    @language = if language == :detect
      detect_language(@path)
    else
      language
    end
  end

  # @rbs return: void
  def view_template
    code_classes = @language ? ["language-#{@language}"] : [] #: Array[String]
    pre(class: "bg-gray-100 p-2 overflow-x-auto") do
      code(class: code_classes) do
        @code
      end
    end
  end

  private

  # @rbs path: String?
  # @rbs return: Symbol?
  def detect_language(path)
    return unless path

    ext = File.extname(path).delete_prefix(".")
    ext.presence&.to_sym
  end
end
