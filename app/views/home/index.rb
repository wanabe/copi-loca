# frozen_string_literal: true

class Views::Home::Index < Views::Base
  def view_template
    h1(class: "text-2xl font-bold mb-4") { "Home" }
    ul(class: "space-y-2") do
      li { link_to "Bin", "/bin", class: "text-blue-600 hover:underline" }
      li { link_to "Files", "/files", class: "text-blue-600 hover:underline" }
      li { link_to "Memos", "/memos", class: "text-blue-600 hover:underline" }
      li { link_to "Ps", "/ps", class: "text-blue-600 hover:underline" }
      li { link_to "Prompts", "/prompts", class: "text-blue-600 hover:underline" }
    end
  end
end
