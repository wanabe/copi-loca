class FilesController < ApplicationController
  def index
    files = Repository.ls_files
    @tree = build_tree(files)
  end

  def show
    @path = params[:path].to_s
    abs_path = Pathname.new("/app").join(@path).expand_path.to_s
    unless abs_path.start_with?(File.expand_path("/app/"))
      render plain: "Invalid path", status: :bad_request
      return
    end
    if File.file?(abs_path)
      @content = File.read(abs_path)
    else
      @content = nil
    end
    render :show
  end

  private

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
