# frozen_string_literal: true
# rbs_inline: enabled

class Git::CommitsController < ApplicationController
  # @rbs @index_parameters: Parameters::Git::Commits::Index

  before_action :add_git_breadcrumb
  before_action :add_git_refs_breadcrumb
  before_action :add_git_ref_breadcrumb
  before_action :add_commits_breadcrumb

  # GET /git/refs/:ref/-/commits
  # @rbs return: void
  def index
    ref = index_parameters.ref || ""
    commits = Kaminari.paginate_array(Git::Log.new(ref: ref).run.commits).page(index_parameters.page).per(index_parameters.per_page || 5)
    render Views::Git::Commits::Index.new(breadcrumbs: breadcrumbs, flash: flash, ref: ref, commits: commits)
  end

  private

  # @rbs return: Parameters::Git::Commits::Index?
  def index_parameters
    return @index_parameters if @index_parameters
    return unless params[:action] == "index"

    @index_parameters = Parameters::Git::Commits::Index.new(params)
  end

  module Breadcrumbs
    include Git::RefsController::Breadcrumbs

    # @rbs return: void
    def add_git_ref_breadcrumb
      add_breadcrumb index_parameters.ref, git_ref_path(ref: index_parameters.ref)
    end

    # @rbs return: void
    def add_commits_breadcrumb
      add_breadcrumb "Commits", git_ref_commits_path(ref: index_parameters.ref)
    end
  end
  include Breadcrumbs
end
