# frozen_string_literal: true
# rbs_inline: enabled

class Views::Files::ShowFile < Views::Base
  # @rbs @content: String
  # @rbs @path: String
  # @rbs @flash: Hash[Symbol, String]
  # @rbs @breadcrumbs: Array[Breadcrumb]

  # @rbs content: String
  # @rbs path: String
  # @rbs flash: Hash[Symbol, String]
  # @rbs breadcrumbs: Array[Breadcrumb]
  # @rbs return: void
  def initialize(content:, path:, flash: {}, breadcrumbs: [])
    super(flash: flash, breadcrumbs: breadcrumbs)
    @content = content
    @path = path
  end

  # @rbs return: void
  def body_template
    content_for :title, "File: #{@path}"
    h1(class: "text-2xl font-bold mb-4") { "File: #{@path}" }
    if @content.valid_encoding? && @content.encoding.name == "UTF-8"
      pre do
        @content
      end
    else
      div(class: "text-red-600") do
        "Binary file (cannot display content)"
      end
    end
  end
end
