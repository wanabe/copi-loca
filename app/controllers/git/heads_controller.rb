# frozen_string_literal: true
# rbs_inline: enabled

class Git::HeadsController < ApplicationController
  before_action :add_git_breadcrumb
  before_action :add_git_refs_breadcrumb
  before_action :add_git_head_breadcrumb
  before_action :add_status_breadcrumb, only: [:new]

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

    render Views::Git::Heads::New.new(
      unstaged_files: unstaged_files,
      untracked_file_map: untracked_file_map,
      unstaged_diff_map: unstaged_diff_map,
      staged_diff_map: staged_diff_map
    )
  end

  # POST /git/refs/HEAD/-/stage
  # Params: file_path
  # @rbs return: void
  def stage
    file_path = params[:file_path]
    Git.call!("add", "--", file_path)
    redirect_to new_git_head_path, notice: "#{file_path} has been staged."
  end

  # POST /git/refs/HEAD/-/unstage
  # Params: file_path
  # @rbs return: void
  def unstage
    file_path = params[:file_path]
    Git.call!("reset", "HEAD", "--", file_path)
    redirect_to new_git_head_path, notice: "#{file_path} has been unstaged."
  end

  module Breadcrumbs
    include Git::RefsController::Breadcrumbs

    private

    # @rbs return: void
    def add_git_head_breadcrumb
      add_breadcrumb("HEAD", git_ref_path(ref: "HEAD"))
    end

    # @rbs return: void
    def add_status_breadcrumb
      add_breadcrumb("Status", new_git_head_path)
    end
  end
  include Breadcrumbs
end
