# frozen_string_literal: true
# rbs_inline: enabled

class Views::Git::Grep::Show < Views::Base
  # @rbs @branches: Array[String]
  # @rbs @pattern: String?
  # @rbs @files: String?
  # @rbs @branch: String?
  # @rbs @ignore_case: bool
  # @rbs @grep: Git::Grep?

  # @rbs branches: Array[String]
  # @rbs pattern: String?
  # @rbs files: String?
  # @rbs branch: String?
  # @rbs ignore_case: bool
  # @rbs grep: Git::Grep?
  # @rbs return: void
  def initialize(branches:, pattern:, files:, branch:, ignore_case:, grep:)
    @branches = branches
    @pattern = pattern
    @files = files
    @branch = branch
    @ignore_case = ignore_case
    @grep = grep
  end

  # @rbs return: void
  def view_template
    h1(class: "text-2xl font-bold mb-4") { "Git Grep" }

    form_with url: git_grep_path, method: :get, local: true do |_f|
      div(class: "space-y-2 mb-4") do
        label(for: "branch", class: "block text-sm font-semibold mb-1") { "Branch:" }
        select(name: "branch", id: "branch", class: "border rounded p-2 w-full") do
          option(value: "", selected: @branch.blank?) { "(local)" }
          @branches.each do |b|
            option(value: b, selected: b == @branch) { b }
          end
        end
      end
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
            if grep.branch.present?
              link_to "#{chunk.path} (#{grep.branch})", git_entry_path(ref: grep.branch, path: chunk.path, raw: "false"),
                class: "text-blue-500 hover:underline"
            else
              link_to chunk.path, file_path(chunk.path, raw: false), class: "text-blue-500 hover:underline"
            end
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
