# frozen_string_literal: true

class Views::Files::Show < Views::Base
  include ERB::Util

  def initialize(path:, content:, language:)
    @path = path
    @content = content
    @language = language
  end

  def view_template
    h1(class: "files-show__title") do
      plain "File: "
      plain @path
    end

    pre do
      code(class: "language-#{@language} files-show__content") { @content }
    end
  end
end
