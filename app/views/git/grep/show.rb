# frozen_string_literal: true
# rbs_inline: enabled

class Views::Git::Grep::Show < Views::Base
  # @rbs @pattern: String?
  # @rbs @files: String?
  # @rbs @ref: String
  # @rbs @ignore_case: bool
  # @rbs @grep: Git::Grep?

  # @rbs pattern: String?
  # @rbs files: String?
  # @rbs ref: String
  # @rbs ignore_case: bool
  # @rbs grep: Git::Grep?
  # @rbs return: void
  def initialize(pattern:, files:, ref:, ignore_case:, grep:)
    @pattern = pattern
    @files = files
    @ref = ref
    @ignore_case = ignore_case
    @grep = grep
  end

  # @rbs return: void
  def view_template
    h1(class: "text-2xl font-bold mb-4") { "Git Grep on #{@ref}" }

    form_with url: git_ref_grep_path(ref: @ref), method: :get, local: true do |_f|
      div(class: "space-y-2 mb-4") do
        label(for: "pattern", class: "block text-sm font-semibold mb-1") { "Pattern:" }
        input(type: "text", name: "pattern", id: "pattern", value: @pattern, class: "border rounded p-2 w-full")
        label(for: "ignore_case", class: "inline-block text-sm font-semibold mr-2") { "Ignore Case" }
        input(type: "checkbox", name: "ignore_case", id: "ignore_case", checked: @ignore_case, class: "mr-2")
      end
      div(class: "space-y-2 mb-4") do
        label(for: "files", class: "block text-sm font-semibold mb-1") { "Files:" }
        textarea(name: "files", id: "files", class: "border rounded p-2 w-full") { @files }
      end
      div(class: "mt-4") do
        button(type: "submit", class: "bg-blue-500 hover:bg-blue-600 text-white font-semibold py-2 px-4 rounded transition") { "Grep" }
      end
    end

    grep = @grep
    chunks = grep&.chunks
    return if !grep || !chunks

    div(class: "mt-6") do
      h2(class: "text-xl font-bold mb-2") { "Results:" }
      chunks.each do |chunk|
        div(class: "mb-4") do
          div(class: "text-xs text-gray-500 mb-1") do
            link_to "#{chunk.path} (#{grep.ref})", git_ref_entry_path(ref: grep.ref, path: chunk.path, raw: "false"),
              class: "text-blue-500 hover:underline"
            plain "(#{chunk.lines.size} matches)"
          end
          div(class: "font-mono text-sm bg-gray-100 p-2 rounded") do
            chunk.lines.each do |line|
              div do
                span { line.content }
              end
            end
          end
        end
      end
    end
  end
end
