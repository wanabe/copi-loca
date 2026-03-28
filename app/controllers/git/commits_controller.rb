# frozen_string_literal: true
# rbs_inline: enabled

class Git::CommitsController < ApplicationController
  before_action :add_git_breadcrumb
  before_action :add_git_refs_breadcrumb
  before_action :add_git_ref_breadcrumb
  before_action :add_commits_breadcrumb

  # GET /git/refs/:ref/-/commits
  # @rbs return: void
  def index
    ref = params[:ref] || ""
    commits = Kaminari.paginate_array(Git::Log.new(ref: ref).run.commits).page(params[:page]).per(params[:per_page] || 5)
    render Views::Git::Commits::Index.new(breadcrumbs: breadcrumbs, flash: flash, ref: ref, commits: commits)
  end

  module Breadcrumbs
    include Git::RefsController::Breadcrumbs

    # @rbs return: void
    def add_commits_breadcrumb
      add_breadcrumb "Commits", git_ref_commits_path(ref: params[:ref])
    end
  end
  include Breadcrumbs
end
