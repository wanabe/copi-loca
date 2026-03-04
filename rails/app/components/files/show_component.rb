# frozen_string_literal: true

class Components::Files::ShowComponent < Components::Base
  include ERB::Util

  def initialize(path:, content:, language:)
    @path = path
    @content = content
    @language = language
  end

  def view_template
    h1(class: "files-show__title") do
      plain "File: "
      plain html_escape(@path)
    end

    pre do
      code(class: "language-#{@language} files-show__content") { plain ERB::Util.html_escape(@content) }
    end
  end
end
