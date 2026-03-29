# frozen_string_literal: true
# rbs_inline: enabled

class Views::Git::Heads::New < Views::Base
  # @rbs @unstaged_files: Array[String]
  # @rbs @untracked_file_map: Hash[String, String]
  # @rbs @unstaged_diff_map: Hash[String, Git::Diff::Patch]
  # @rbs @staged_diff_map: Hash[String, Git::Diff::Patch]
  # @rbs @flash: Hash[Symbol, String]
  # @rbs @breadcrumbs: Array[Breadcrumb]
  # @rbs @open: String?

  # @rbs unstaged_files: Array[String]
  # @rbs untracked_file_map: Hash[String, String]
  # @rbs unstaged_diff_map: Hash[String, Git::Diff::Patch]
  # @rbs staged_diff_map: Hash[String, Git::Diff::Patch]
  # @rbs flash: Hash[Symbol, String]
  # @rbs breadcrumbs: Array[Breadcrumb]
  # @rbs open: String?
  # @rbs return: void
  def initialize(unstaged_files:, untracked_file_map:, unstaged_diff_map:, staged_diff_map:, flash: {}, breadcrumbs: [], open: nil)
    super(flash: flash, breadcrumbs: breadcrumbs)
    @unstaged_files = unstaged_files
    @untracked_file_map = untracked_file_map
    @unstaged_diff_map = unstaged_diff_map
    @staged_diff_map = staged_diff_map
    @open = open
  end

  # @rbs return: void
  def body_template
    h1(class: "text-2xl font-bold mb-4 flex items-center") do
      span { "Git HEAD status" }
      link_to("amend", edit_git_head_path, class: "ml-2 text-xs text-blue-600 hover:underline")
    end
    render Components::Git::HeadForm.new(
      unstaged_files: @unstaged_files,
      untracked_file_map: @untracked_file_map,
      unstaged_diff_map: @unstaged_diff_map,
      staged_diff_map: @staged_diff_map,
      commit_message: nil,
      form_action: "/git/refs/HEAD",
      form_method: :post,
      submit_label: "Commit",
      open: @open
    )
  end
end
