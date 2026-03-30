# frozen_string_literal: true
# rbs_inline: enabled

class Git::HeadsController < ApplicationController
  # @rbs @new_parameters: Parameters::Git::Heads::New?
  # @rbs @edit_parameters: Parameters::Git::Heads::Edit?
  # @rbs @create_parameters: Parameters::Git::Heads::Create?
  # @rbs @update_parameters: Parameters::Git::Heads::Update?
  # @rbs @stage_parameters: Parameters::Git::Heads::Stage?
  # @rbs @unstage_parameters: Parameters::Git::Heads::Unstage?
  # @rbs @stage_line_parameters: Parameters::Git::Heads::StageLine?
  # @rbs @unstage_line_parameters: Parameters::Git::Heads::Unstage

  # @rbs!
  #   def new_parameters: () -> Parameters::Git::Heads::New?
  #   def edit_parameters: () -> Parameters::Git::Heads::Edit?
  #   def create_parameters: () -> Parameters::Git::Heads::Create?
  #   def update_parameters: () -> Parameters::Git::Heads::Update?
  #   def stage_parameters: () -> Parameters::Git::Heads::Stage?
  #   def unstage_parameters: () -> Parameters::Git::Heads::Unstage?
  #   def stage_line_parameters: () -> Parameters::Git::Heads::StageLine?
  #   def unstage_line_parameters: () -> Parameters::Git::Heads::UnstageLine?

  parameters :new, :edit, :create, :update, :stage, :unstage, :stage_line, :unstage_line

  before_action :add_git_breadcrumb
  before_action :add_git_refs_breadcrumb
  before_action :add_git_head_breadcrumb
  before_action :add_new_status_breadcrumb, only: [:new]
  before_action :add_edit_breadcrumb, only: [:edit]

  # @rbs return: void
  def new
    untracked_files = Git::LsFiles.new(others: true, exclude_standard: true).run
    untracked_file_map = untracked_files.entries.to_h { |entry| [entry.path, File.read(entry.path)] }
    unstaged_diff = Git::Diff.new.run
    staged_diff = Git::Diff.new(dst_ref: "HEAD", cached: true).run
    unstaged_files = unstaged_diff.patches.map { |patch| patch.header.src_path } + untracked_files.entries.map(&:path)
    unstaged_files.sort!
    unstaged_diff_map = unstaged_diff.patches.index_by { |patch| patch.header.src_path }
    staged_diff_map = staged_diff.patches.index_by { |patch| patch.header.dst_path }
    open = new_parameters.open

    render Views::Git::Heads::New.new(
      breadcrumbs: breadcrumbs, flash: flash,
      unstaged_files: unstaged_files,
      untracked_file_map: untracked_file_map,
      unstaged_diff_map: unstaged_diff_map,
      staged_diff_map: staged_diff_map,
      open: open
    )
  end

  # GET /git/refs/HEAD/edit
  # @rbs return: void
  def edit
    # Get HEAD commit message
    log = Git::Log.new(ref: "HEAD").run
    commit_message = log.commits.first&.message || ""

    untracked_files = Git::LsFiles.new(others: true, exclude_standard: true).run
    untracked_file_map = untracked_files.entries.to_h { |entry| [entry.path, File.read(entry.path)] }
    unstaged_diff = Git::Diff.new.run
    # For staged, compare with HEAD~ (previous commit)
    staged_diff = Git::Diff.new(dst_ref: "HEAD~", cached: true).run
    unstaged_files = unstaged_diff.patches.map { |patch| patch.header.src_path } + untracked_files.entries.map(&:path)
    unstaged_files.sort!
    unstaged_diff_map = unstaged_diff.patches.index_by { |patch| patch.header.src_path }
    staged_diff_map = staged_diff.patches.index_by { |patch| patch.header.dst_path }
    open = edit_parameters.open

    render Views::Git::Heads::Edit.new(
      breadcrumbs: breadcrumbs, flash: flash,
      unstaged_files: unstaged_files,
      untracked_file_map: untracked_file_map,
      unstaged_diff_map: unstaged_diff_map,
      staged_diff_map: staged_diff_map,
      commit_message: commit_message,
      open: open
    )
  end

  # POST /git/refs/HEAD
  # Params: commit_message
  # @rbs return: void
  def create
    commit_message = create_parameters.commit_message
    begin
      Git.call!("commit", "-m", commit_message)
      redirect_to new_git_head_path, notice: "Committed successfully."
    rescue StandardError => e
      redirect_to new_git_head_path, alert: "Failed to commit: #{e.message}"
    end
  end

  # PATCH /git/refs/HEAD
  # Params: commit_message
  # @rbs return: void
  def update
    commit_message = update_parameters.commit_message
    begin
      Git.call!("commit", "--amend", "-m", commit_message)
      redirect_to new_git_head_path, notice: "Amended commit successfully."
    rescue StandardError => e
      redirect_to edit_git_head_path, alert: "Failed to amend commit: #{e.message}"
    end
  end

  # POST /git/refs/HEAD/-/stage
  # Params: file_path, amend (optional)
  # @rbs return: void
  def stage
    amend = stage_parameters.amend
    file_path = stage_parameters.file_path
    Git.call!("add", "--", file_path)
    redirect_path = amend ? edit_git_head_path : new_git_head_path
    redirect_to redirect_path, notice: "#{file_path} has been staged."
  end

  # POST /git/refs/HEAD/-/unstage
  # Params: file_path, amend (optional)
  # @rbs return: void
  def unstage
    amend = unstage_parameters.amend
    file_path = unstage_parameters.file_path
    target_ref = amend ? "HEAD~" : "HEAD"
    Git.call!("reset", target_ref, "--", file_path)
    redirect_path = amend ? edit_git_head_path : new_git_head_path
    redirect_to redirect_path, notice: "#{file_path} has been unstaged."
  end

  # POST /git/refs/HEAD/-/stage_line
  # Params: path, hunk, lineno, for
  # @rbs return: void
  def stage_line
    path = stage_line_parameters.path
    lineno = stage_line_parameters.lineno
    for_param = stage_line_parameters.for
    hunk_str = stage_line_parameters.hunk
    raise "Missing hunk parameter" if hunk_str.blank?

    Git::Apply.pick_line(path, hunk_str, lineno)
    if for_param == "edit"
      redirect_to edit_git_head_path(open: path), notice: "Line has been staged"
    else
      redirect_to new_git_head_path(open: path), notice: "Line has been staged"
    end
  end

  # POST /git/refs/HEAD/-/unstage_line
  # Params: path, hunk, lineno, for
  # @rbs return: void
  def unstage_line
    path = unstage_line_parameters.path
    lineno = unstage_line_parameters.lineno
    for_param = unstage_line_parameters.for
    hunk_str = unstage_line_parameters.hunk
    raise "Missing hunk parameter" if hunk_str.blank?

    Git::Apply.pick_line(path, hunk_str, lineno, reverse: true)
    if for_param == "edit"
      redirect_to edit_git_head_path(open: path), notice: "Line has been unstaged"
    else
      redirect_to new_git_head_path(open: path), notice: "Line has been unstaged"
    end
  end

  module Breadcrumbs
    include Git::RefsController::Breadcrumbs

    private

    # @rbs return: void
    def add_git_head_breadcrumb
      add_breadcrumb("HEAD", git_ref_path(ref: "HEAD"))
    end

    # @rbs return: void
    def add_new_status_breadcrumb
      add_breadcrumb("Status", new_git_head_path)
    end

    # @rbs return: void
    def add_edit_breadcrumb
      add_breadcrumb("Status (amend)", edit_git_head_path)
    end
  end
  include Breadcrumbs
end
