class FilesController < ApplicationController
  def index
    @files = `git ls-files -c -o --exclude-standard`.chomp.split("\n")
  end
end
