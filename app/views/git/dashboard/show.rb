# frozen_string_literal: true
# rbs_inline: enabled

class Views::Git::Dashboard::Show < Views::Base
  # @rbs return: void
  def view_template
    h1(class: "text-2xl font-bold mb-4") { "Git" }
    ul(class: "space-y-2") do
      li { link_to "Grep", "/git/grep", class: "text-blue-600 hover:underline" }
    end
  end
end
