class FilesController < ApplicationController
  def index
    files = `git ls-files -c -o --exclude-standard`.chomp.split("\n")
    @tree = build_tree(files)
  end

  private

  def build_tree(paths)
    tree = {}
    paths.each do |path|
      parts = path.split('/')
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
