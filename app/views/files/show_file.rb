# frozen_string_literal: true

class Views::Files::ShowFile < Views::Base
  def initialize(content:, path:)
    @content = content
    @path = path
  end

  def view_template
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
