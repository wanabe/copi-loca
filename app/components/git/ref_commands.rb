# frozen_string_literal: true
# rbs_inline: enabled

class Components::Git::RefCommands < Components::Base
  # @rbs @ref: String

  # @rbs ref: String
  # @rbs return: void
  def initialize(ref:)
    @ref = ref
  end

  # @rbs return: void
  def view_template
    ul(class: "space-y-2") do
      li { link_to "Grep", git_ref_grep_path(ref: @ref), class: "text-blue-600 hover:underline" }
      li { link_to "Commits", git_ref_commits_path(ref: @ref), class: "text-blue-600 hover:underline" }
      li { link_to "Entries", git_ref_entries_root_path(ref: @ref), class: "text-blue-600 hover:underline" }
    end
  end
end
