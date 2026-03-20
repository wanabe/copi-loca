# frozen_string_literal: true

class Views::Git::Dashboard::Show < Views::Base
  def view_template
    h1(class: "text-2xl font-bold mb-4") { "Git" }
    ul(class: "space-y-2") do
      li { link_to "Grep", "/git/grep", class: "text-blue-600 hover:underline" }
    end
  end
end
