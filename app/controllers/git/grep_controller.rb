# frozen_string_literal: true
# rbs_inline: enabled

class Git::GrepController < ApplicationController
  before_action :add_git_breadcrumb
  before_action :add_grep_breadcrumb

  # @rbs @branches: Array[String]
  # @rbs @pattern: String?
  # @rbs @files: String
  # @rbs @branch: String
  # @rbs @ignore_case: bool
  # @rbs @grep_result: String?

  # GET /git/grep
  # @rbs return: void
  def show
    @branches = branches
    @pattern = params[:pattern]
    @files = params[:files] || ""
    @branch = params[:branch] || ""
    @ignore_case = params[:ignore_case] == "on"
    @grep_result = nil

    pattern = @pattern
    if pattern.present?
      @grep_result = Git::Grep.new(
        pattern: pattern,
        branch: @branch,
        files: @files,
        ignore_case: @ignore_case
      ).run.render
    end

    render Views::Git::Grep::Show.new(
      branches: @branches,
      pattern: @pattern,
      files: @files,
      branch: @branch,
      ignore_case: @ignore_case,
      grep_result: @grep_result
    )
  end

  private

  # def add_grep_breadcrumb: () -> void
  # @rbs return: void
  def add_grep_breadcrumb
    add_breadcrumb "Grep", git_grep_path
  end

  # def branches: () -> Array[String]
  # @rbs return: Array[String]
  def branches
    local = `git branch --format='%(refname:short)'`.lines.map(&:strip)
    remote = `git branch -r --format='%(refname:short)'`.lines.map(&:strip)
    [*local, *remote]
  end
end
