# frozen_string_literal: true
# rbs_inline: enabled

class Views::Git::Dashboard::Show < Views::Base
  # @rbs return: void
  def view_template
    h1(class: "text-2xl font-bold mb-4") { "Git" }
    ul(class: "space-y-2") do
      li { link_to "Refs", git_refs_path, class: "text-blue-600 hover:underline" }
      li do
        ul(class: "space-y-1 ml-4") do
          li { "for HEAD" }
          li do
            render Components::Git::RefCommands.new(ref: "HEAD")
          end
        end
      end
    end
  end
end
