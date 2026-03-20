# frozen_string_literal: true

class Git::GrepController < ApplicationController
  before_action :add_git_breadcrumb
  before_action :add_action_breadcrumb, only: [:show]

  def show
    @branches = branches
    @pattern = params[:pattern]
    @files = params[:files]
    @branch = params[:branch]
    @ignore_case = params[:ignore_case] == "on"
    @grep_result = nil

    @grep_result = run_git_grep(@pattern, @files, @branch, @ignore_case) if @pattern.present?

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

  def branches
    local = `git branch --format='%(refname:short)'`.lines.map(&:strip)
    remote = `git branch -r --format='%(refname:short)'`.lines.map(&:strip)
    [*local, *remote]
  end

  def run_git_grep(pattern, files, branch, ignore_case)
    cmd = %w[git grep]
    cmd << "-i" if ignore_case
    cmd << pattern
    cmd << branch if branch.present?
    if files.present?
      cmd << "--"
      files.split("\n").each do |file|
        cmd << file.strip
      end
    end
    IO.popen(cmd, &:read)
  end
end
