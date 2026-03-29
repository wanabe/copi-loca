# frozen_string_literal: true
# rbs_inline: enabled

class Components::Git::HeadForm < Components::Base
  # @rbs @unstaged_files: Array[String]
  # @rbs @untracked_file_map: Hash[String, String]
  # @rbs @unstaged_diff_map: Hash[String, Git::Diff::Patch]
  # @rbs @staged_diff_map: Hash[String, Git::Diff::Patch]
  # @rbs @commit_message: String?
  # @rbs @form_action: String
  # @rbs @form_method: Symbol
  # @rbs @submit_label: String
  # @rbs @flash: Hash[Symbol, String]
  # @rbs @breadcrumbs: Array[Breadcrumb]
  # @rbs @open: String?

  ICON_MAP = {
    new: "\u{2795}\u{FE0F}",
    modify: "\u{270D}\u{FE0F}",
    delete: "\u{274C}\u{FE0F}"
  }.freeze

  # @rbs unstaged_files: Array[String]
  # @rbs untracked_file_map: Hash[String, String]
  # @rbs unstaged_diff_map: Hash[String, Git::Diff::Patch]
  # @rbs staged_diff_map: Hash[String, Git::Diff::Patch]
  # @rbs commit_message: String?
  # @rbs form_action: String
  # @rbs form_method: Symbol
  # @rbs submit_label: String
  # @rbs flash: Hash[Symbol, String]
  # @rbs breadcrumbs: Array[Breadcrumb]
  # @rbs open: String?
  # @rbs return: void
  def initialize(unstaged_files:, untracked_file_map:, unstaged_diff_map:, staged_diff_map:, form_action:, form_method:, submit_label:,
                 commit_message: nil, flash: {}, breadcrumbs: [], open: nil)
    @unstaged_files = unstaged_files
    @untracked_file_map = untracked_file_map
    @unstaged_diff_map = unstaged_diff_map
    @staged_diff_map = staged_diff_map
    @commit_message = commit_message
    @form_action = form_action
    @form_method = form_method
    @submit_label = submit_label
    @flash = flash
    @breadcrumbs = breadcrumbs
    @open = open
  end

  # @rbs return: void
  def view_template
    form(method: @form_method, action: @form_action) do
      textarea(name: "commit_message", rows: 3, class: "w-full p-2 border rounded mb-2", placeholder: "Commit message...",
        value: @commit_message) do
        @commit_message if @commit_message
      end
      br
      button(type: "submit", class: "bg-blue-600 text-white px-4 py-2 rounded") { @submit_label }
    end

    h3(class: "text-xl font-semibold") { "Unstaged" }
    @unstaged_files.each do |path|
      div do
        patch = @unstaged_diff_map[path]
        file_content = @untracked_file_map[path]
        if patch
          render_chunk(:unstaged, patch.type, path) do
            render Components::Git::Patch.new(path: path, patch: patch, action: "stage_line", for_param: @form_method == :patch ? "edit" : "new")
          end
        elsif file_content
          render_chunk(:unstaged, :new, path) do
            render Components::Code.new(code: file_content, path: path, language: :detect)
          end
        end
      end
    end

    h3(class: "text-xl font-semibold") { "Staged" }
    @staged_diff_map.each do |path, patch|
      div do
        render_chunk(:staged, patch.type, path) do
          render Components::Git::Patch.new(path: path, patch: patch, action: "unstage_line", for_param: @form_method == :patch ? "edit" : "new")
        end
      end
    end
  end

  private

  # @rbs section: :staged | :unstaged
  # @rbs type: Symbol
  # @rbs path: String
  # @rbs return: void
  def render_chunk(section, type, path, &)
    div(class: "flex items-start space-x-2") do
      form(method: :post, action: "/git/refs/HEAD/-/#{section == :unstaged ? 'stage' : 'unstage'}") do
        input(type: "hidden", name: "file_path", value: path)
        input(type: "hidden", name: "amend", value: "true") if @form_method == :patch
        button(type: "submit", class: "text-blue-600 hover:underline") { ICON_MAP[type] || "\u{2753}\u{FE0F}" }
      end
      details(open: @open == path) do
        summary(class: "list-none") do
          span(class: "text-sm text-gray-600") { path }
        end
        yield
      end
    end
  end
end
