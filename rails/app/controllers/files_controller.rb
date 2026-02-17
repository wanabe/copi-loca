class FilesController < ApplicationController
  before_action :set_path, only: [ :show ]

  before_action :add_files_breadcrumb
  before_action :add_filepath_breadcrumb, only: [ :show ]

  def index
    files = Repository.ls_files
    @tree = build_tree(files)
  end

  def show
    abs_path = Pathname.new("/app").join(@path).expand_path.to_s
    unless abs_path.start_with?(File.expand_path("/app/"))
      render plain: "Invalid path", status: :bad_request
      return
    end
    if File.file?(abs_path)
      @language = abs_path[/\.(\w+)$/, 1] || "txt"
      @content = File.read(abs_path)
    else
      @content = nil
    end
    render :show
  end

  private

  def set_path
    @path = params[:path].to_s
  end

  def add_files_breadcrumb
    add_breadcrumb("Files", files_path)
  end

  def add_filepath_breadcrumb
    parts = @path.split("/")
    parts.each do |part|
      add_breadcrumb(part)
    end
  end

  def build_tree(paths)
    tree = {}
    paths.each do |path|
      parts = path.split("/")
      current = tree
      parts.each_with_index do |part, i|
        if i == parts.size - 1
          (current[:files] ||= []) << part
        else
          current[:dirs] ||= {}
          current = (current[:dirs][part] ||= {})
        end
      end
    end
    tree
  end
end
