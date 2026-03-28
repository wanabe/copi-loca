# frozen_string_literal: true
# rbs_inline: enabled

class Git::GrepController < ApplicationController
  before_action :add_git_breadcrumb
  before_action :add_git_refs_breadcrumb
  before_action :add_git_ref_breadcrumb
  before_action :add_grep_breadcrumb

  # @rbs @pattern: String?
  # @rbs @files: String
  # @rbs @branch: String
  # @rbs @ignore_case: bool
  # @rbs @grep: Git::Grep?

  # GET /git/grep
  # @rbs return: void
  def show
    pattern = params[:pattern]
    files = params[:files] || ""
    ref = params[:ref] || ""
    ignore_case = params[:ignore_case] == "on"
    grep = nil

    if pattern.present?
      grep = Git::Grep.new(
        pattern: pattern,
        ref: ref,
        files: files,
        ignore_case: ignore_case
      ).run
    end

    render Views::Git::Grep::Show.new(
      breadcrumbs: breadcrumbs, flash: flash,
      pattern: pattern,
      files: files,
      ref: ref,
      ignore_case: ignore_case,
      grep: grep
    )
  end

  module Breadcrumbs
    include Git::RefsController::Breadcrumbs

    # @rbs return: void
    def add_grep_breadcrumb
      add_breadcrumb "Grep", git_ref_grep_path(ref: params[:ref])
    end
  end
  include Breadcrumbs
end
