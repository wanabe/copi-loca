# frozen_string_literal: true
# rbs_inline: enabled

class Git::EntriesController < ApplicationController
  # @rbs @parameters: Parameters::Git::Entries::Show

  before_action :add_git_breadcrumb
  before_action :add_git_refs_breadcrumb
  before_action :add_git_ref_breadcrumb
  before_action :add_git_ref_entries_breadcrumb
  before_action :add_git_ref_entry_path_breadcrumb, only: [:show]

  # GET /git/entries/*ref/-/*path or /git/entries/*ref
  # @rbs return: void
  def show
    if parameters.path.present?
      ls_tree = Git::LsTree.new(ref: parameters.ref, path: parameters.path).run
      if ls_tree.entries.blank?
        render json: { error: "Not found", ref: parameters.ref, path: parameters.path }, status: :not_found
        return
      end
      if ls_tree.entries.size > 1
        render json: { error: "Multiple entries found", ref: parameters.ref, path: parameters.path }, status: :unprocessable_content
        return
      end
      entry = ls_tree.entries.first
    else
      entry = Git::LsTree::Entry.new(type: "tree", path: ".", mode: "40000", hash: "")
    end

    case entry.type
    when "tree"
      entries = Git::LsTree.new(ref: parameters.ref, path: "#{entry.path}/").run.entries
      render Views::Git::Entries::ShowTree.new(breadcrumbs: breadcrumbs, flash: flash, ref: parameters.ref, path: entry.path, entries: entries),
        format: :html
    when "blob"
      content = Git::Show.new(ref: parameters.ref, path: entry.path).run.content
      if parameters.raw
        send_data content, filename: File.basename(entry.path), disposition: "inline"
        return
      end
      request.format = :html
      render Views::Git::Entries::ShowBlob.new(breadcrumbs: breadcrumbs, flash: flash, ref: parameters.ref, path: entry.path, content: content)
    else
      render json: { error: "Unsupported entry type", ref: parameters.ref, path: parameters.path, type: entry.type }, status: :unsupported_media_type
    end
  end

  private

  # @rbs return: Parameters::Git::Entries::Show
  def parameters
    @parameters ||= Parameters::Git::Entries::Show.new(**params.permit(:path, :ref, :raw))
  end

  module Breadcrumbs
    include Git::RefsController::Breadcrumbs

    # @rbs return: void
    def add_git_ref_entries_breadcrumb
      add_breadcrumb "Entries", git_ref_entries_root_path(ref: parameters.ref)
    end

    # @rbs return: void
    def add_git_ref_entry_path_breadcrumb
      return if parameters.path.blank?

      path = parameters.path
      parts = path.split("/").reject(&:empty?)
      accumulated_path = nil
      parts.each do |part|
        accumulated_path = accumulated_path ? File.join(accumulated_path, part) : part
        add_breadcrumb(part, git_ref_entry_path(ref: parameters.ref, path: accumulated_path))
      end
    end
  end
  include Breadcrumbs
end
