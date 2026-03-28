# frozen_string_literal: true
# rbs_inline: enabled

class Views::Git::Heads::New < Views::Base
  ICON_MAP = {
    new: "\u{2795}\u{FE0F}",
    modify: "\u{270D}\u{FE0F}",
    delete: "\u{274C}\u{FE0F}"
  }.freeze

  # @rbs @unstaged_files: Array[String]
  # @rbs @unstaged_diff_map: Hash[String, Git::Diff::Patch]
  # @rbs @staged_diff_map: Hash[String, Git::Diff::Patch]
  # @rbs @untracked_file_map: Hash[String, String]
  # @rbs @flash: Hash[Symbol, String]
  # @rbs @breadcrumbs: Array[Breadcrumb]

  # @rbs unstaged_files: Array[String]
  # @rbs unstaged_diff_map: Hash[String, Git::Diff::Patch]
  # @rbs staged_diff_map: Hash[String, Git::Diff::Patch]
  # @rbs untracked_file_map: Hash[String, String]
  # @rbs flash: Hash[Symbol, String]
  # @rbs breadcrumbs: Array[Breadcrumb]
  # @rbs return: void
  def initialize(unstaged_files:, untracked_file_map:, unstaged_diff_map:, staged_diff_map:, flash: {}, breadcrumbs: [])
    super(flash: flash, breadcrumbs: breadcrumbs)
    @unstaged_files = unstaged_files
    @untracked_file_map = untracked_file_map
    @unstaged_diff_map = unstaged_diff_map
    @staged_diff_map = staged_diff_map
  end

  # @rbs return: void
  def body_template
    h1(class: "text-2xl font-bold mb-4 flex items-center") do
      span { "Git HEAD status" }
      link_to("amend", edit_git_head_path, class: "ml-2 text-xs text-blue-600 hover:underline")
    end

    form(method: :post, action: "/git/refs/HEAD") do
      textarea(name: "commit_message", rows: 3, class: "w-full p-2 border rounded mb-2", placeholder: "Commit message...")
      br
      button(type: "submit", class: "bg-blue-600 text-white px-4 py-2 rounded") { "Commit" }
    end

    h3(class: "text-xl font-semibold") { "Unstaged" }
    @unstaged_files.each do |path|
      div do
        patch = @unstaged_diff_map[path]
        file_content = @untracked_file_map[path]
        if patch
          render_chunk_with_stage(:unstaged, patch.type, path, patch.render)
        elsif file_content
          render_chunk_with_stage(:unstaged, :new, path, file_content)
        end
      end
    end

    h3(class: "text-xl font-semibold") { "Staged" }
    @staged_diff_map.each do |path, patch|
      div do
        render_chunk_with_stage(:staged, patch.type, path, patch.render)
      end
    end
  end

  private

  # @rbs section: Symbol (:unstaged or :staged)
  # @rbs type: Symbol
  # @rbs path: String
  # @rbs content: String
  # @rbs return: void
  def render_chunk_with_stage(section, type, path, content)
    div(class: "flex items-start space-x-2") do
      form(method: :post, action: "/git/refs/HEAD/-/#{section == :unstaged ? 'stage' : 'unstage'}") do
        input(type: "hidden", name: "file_path", value: path)
        button(type: "submit", class: "text-blue-600 hover:underline") { ICON_MAP[type] || "\u{2753}\u{FE0F}" }
      end
      details do
        summary(class: "list-none") do
          span(class: "text-sm text-gray-600") { path }
        end
        pre(class: "bg-gray-100 p-2 overflow-x-auto") do
          code do
            content
          end
        end
      end
    end
  end
end
