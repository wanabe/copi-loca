# frozen_string_literal: true
# rbs_inline: enabled

class Views::Git::Entries::ShowBlob < Views::Base
  # @rbs @ref: String
  # @rbs @content: String
  # @rbs @path: String

  # @rbs ref: String
  # @rbs content: String
  # @rbs path: String
  # @rbs return: void
  def initialize(ref:, content:, path:)
    @ref = ref
    @content = content
    @path = path
  end

  # @rbs return: void
  def view_template
    content_for :title, "Blob #{@ref}:#{@path}"
    h1(class: "text-2xl font-bold mb-4") { "Blob #{@ref}:#{@path}" }
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
