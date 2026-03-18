# frozen_string_literal: true

class FilesController < ApplicationController
  skip_forgery_protection only: [:show]

  before_action :add_files_breadcrumb
  before_action :add_path_breadcrumb, only: [:show]

  # GET /files/*path
  def show
    path = params[:path] || "."
    abs = File.absolute_path(File.join("/app", path))
    unless File.exist?(abs)
      render json: { error: "File not found", path: path }, status: :not_found
      return
    end
    if abs != "/app" && !abs.start_with?("/app/")
      render json: { error: "Invalid path" }, status: :bad_request
      return
    end
    case File.ftype(abs)
    when "directory"
      entries = Dir.entries(abs).reject { |e| %w[. ..].include?(e) }.map do |entry|
        entry_path = File.join(abs, entry)
        [File.ftype(entry_path), entry]
      end.sort
      render Views::Files::ShowDirectory.new(entries: entries, path: path)
    when "file"
      if params[:raw] != "false"
        send_file abs, filename: File.basename(abs), disposition: "inline"
        return
      end
      content = File.read(abs)
      render Views::Files::ShowFile.new(content: content, path: path)
    else
      render json: { error: "Unsupported file type", path: path }, status: :unsupported_media_type
    end
  end

  private

  def add_files_breadcrumb
    add_breadcrumb("Files", files_path)
  end

  def add_path_breadcrumb
    return unless params[:path]

    path = params[:path]
    parts = path.split("/").reject(&:empty?)
    accumulated_path = ""
    parts.each do |part|
      accumulated_path = File.join(accumulated_path, part)
      add_breadcrumb(part, files_path(path: accumulated_path))
    end
  end
end
