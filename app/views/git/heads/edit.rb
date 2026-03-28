# frozen_string_literal: true
# rbs_inline: enabled

class Views::Git::Heads::Edit < Views::Base
  # @rbs @unstaged_files: Array[String]
  # @rbs @untracked_file_map: Hash[String, String]
  # @rbs @unstaged_diff_map: Hash[String, Git::Diff::Patch]
  # @rbs @staged_diff_map: Hash[String, Git::Diff::Patch]
  # @rbs @commit_message: String
  # @rbs @flash: Hash[Symbol, String]
  # @rbs @breadcrumbs: Array[Breadcrumb]

  # @rbs unstaged_files: Array[String]
  # @rbs untracked_file_map: Hash[String, String]
  # @rbs unstaged_diff_map: Hash[String, Git::Diff::Patch]
  # @rbs staged_diff_map: Hash[String, Git::Diff::Patch]
  # @rbs commit_message: String
  # @rbs flash: Hash[Symbol, String]
  # @rbs breadcrumbs: Array[Breadcrumb]
  # @rbs return: void
  def initialize(unstaged_files:, untracked_file_map:, unstaged_diff_map:, staged_diff_map:, commit_message:, flash: {}, breadcrumbs: [])
    super(flash: flash, breadcrumbs: breadcrumbs)
    @unstaged_files = unstaged_files
    @untracked_file_map = untracked_file_map
    @unstaged_diff_map = unstaged_diff_map
    @staged_diff_map = staged_diff_map
    @commit_message = commit_message
  end

  # @rbs return: void
  def body_template
    h1(class: "text-2xl font-bold mb-4 flex items-center") do
      span { "Git HEAD amend" }
      link_to("HEAD", new_git_head_path, class: "ml-2 text-xs text-blue-600 hover:underline")
    end
    render Components::Git::HeadForm.new(
      unstaged_files: @unstaged_files,
      untracked_file_map: @untracked_file_map,
      unstaged_diff_map: @unstaged_diff_map,
      staged_diff_map: @staged_diff_map,
      commit_message: @commit_message,
      form_action: git_head_path,
      form_method: :patch,
      submit_label: "Amend Commit"
    )
  end
end
