# frozen_string_literal: true
# rbs_inline: enabled

class Git::RefsController < ApplicationController
  before_action :add_git_breadcrumb
  before_action :add_git_refs_breadcrumb
  before_action :add_git_ref_breadcrumb, only: [:show]

  # GET /git/refs
  # @rbs return: void
  def index
    render Views::Git::Refs::Index.new(breadcrumbs: breadcrumbs, flash: flash, refs: refs)
  end

  # GET /git/refs/*ref
  # @rbs return: void
  def show
    ref = params[:ref]
    render Views::Git::Refs::Show.new(breadcrumbs: breadcrumbs, flash: flash, ref: ref)
  end

  private

  # @rbs return: Array[String]
  def refs
    local = Git.call("branch", "--format=%(refname:short)").lines.map(&:strip)
    remote = Git.call("branch", "-r", "--format=%(refname:short)").lines.map(&:strip)
    ["HEAD", *local, *remote]
  end

  module Breadcrumbs
    include Git::DashboardController::Breadcrumbs

    private

    # @rbs return: void
    def add_git_refs_breadcrumb
      add_breadcrumb("Refs", git_refs_path)
    end

    # @rbs return: void
    def add_git_ref_breadcrumb
      add_breadcrumb params[:ref], git_ref_path(ref: params[:ref])
    end
  end
  include Breadcrumbs
end
