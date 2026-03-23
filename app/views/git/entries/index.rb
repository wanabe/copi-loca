# frozen_string_literal: true
# rbs_inline: enabled

class Views::Git::Entries::Index < Views::Base
  # @rbs @branches: Array[String]

  # @rbs branches: Array[String]
  # @rbs return: void
  def initialize(branches:)
    @branches = branches
  end

  # @rbs return: void
  def view_template
    content_for :title, "Branches"
    h1(class: "text-2xl font-bold mb-4") { "Branches" }
    if @branches.any?
      ul do
        @branches.each do |branch|
          li do
            link_to branch, git_entry_root_path(ref: branch), class: "text-blue-600 hover:underline"
          end
        end
      end
    else
      div(class: "text-red-600") do
        "No branches found"
      end
    end
  end
end
