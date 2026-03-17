# frozen_string_literal: true

class Views::Files::ShowDirectory < Views::Base
  def initialize(entries:, path:)
    @entries = entries
    @path = path
  end

  def view_template
    content_for :title, "Directory: #{@path}"
    h1(class: "text-2xl font-bold mb-4") { "Directory: #{@path}" }
    ul do
      @entries.each do |type, name|
        path = File.join(@path, name)
        li do
          case type
          when "directory"
            span(class: "mr-1") do
              "\u{1F4C1} "
            end
            link_to name, file_path(path: path), class: "text-blue-600 hover:underline"
          when "file"
            span(class: "mr-1") do
              "\u{1F4C4} "
            end
            link_to name, file_path(path: path, raw: "false"), class: "text-gray-600 hover:underline"
            link_to " (raw)", file_path(path: path), class: "text-gray-400 hover:underline"
          else
            span(class: "mr-1") do
              "\u{2753} "
            end
            plain name
          end
        end
      end
    end
  end
end
