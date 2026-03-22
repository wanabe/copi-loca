# frozen_string_literal: true
# rbs_inline: enabled

class FilesController < ApplicationController
  # @rbs @show_parameters: Parameters::Files::Show

  skip_forgery_protection only: [:show]

  before_action :add_files_breadcrumb
  before_action :add_path_breadcrumb, only: [:show]

  # GET /files/*path
  # @rbs return: void
  def show
    path = show_parameters.path
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
      if show_parameters.raw
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

  # @rbs return: Parameters::Files::Show
  def show_parameters
    @show_parameters ||= Parameters::Files::Show.new(**params.permit(:path, :raw))
  end

  # @rbs return: void
  def add_files_breadcrumb
    add_breadcrumb("Files", files_path)
  end

  # @rbs return: void
  def add_path_breadcrumb
    return if show_parameters.path == "."

    path = show_parameters.path
    parts = path.split("/").reject(&:empty?)
    accumulated_path = ""
    parts.each do |part|
      accumulated_path = File.join(accumulated_path, part)
      add_breadcrumb(part, files_path(path: accumulated_path))
    end
  end
end
