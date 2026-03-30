# frozen_string_literal: true
# rbs_inline: enabled

class Git::GrepController < ApplicationController
  # @rbs @git_ref: String
  # @rbs @show_parameters: Parameters::Git::Grep::Show

  before_action :add_git_breadcrumb
  before_action :add_git_refs_breadcrumb
  before_action :add_git_ref_breadcrumb
  before_action :add_grep_breadcrumb

  # GET /git/grep
  # @rbs return: void
  def show
    pattern = show_parameters.pattern
    files = show_parameters.files || ""
    ref = show_parameters.ref || ""
    ignore_case = show_parameters.ignore_case
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

  private

  # @rbs return: Parameters::Git::Grep::Show?
  def show_parameters
    return @show_parameters if @show_parameters
    return unless params[:action] == "show"

    @show_parameters = Parameters::Git::Grep::Show.new(params)
  end

  # @rbs return: String
  def git_ref
    @git_ref ||= show_parameters&.ref || ""
  end

  module Breadcrumbs
    include Git::RefsController::Breadcrumbs

    # @rbs return: void
    def add_grep_breadcrumb
      add_breadcrumb "Grep", git_ref_grep_path(ref: git_ref)
    end
  end
  include Breadcrumbs
end
