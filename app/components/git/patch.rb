# frozen_string_literal: true
# rbs_inline: enabled

class Components::Git::Patch < Components::Base
  # @rbs @path: String
  # @rbs @patch: Git::Diff::Patch
  # @rbs @action: String
  # @rbs @for_param: String

  # @rbs path: String
  # @rbs patch: Git::Diff::Patch
  # @rbs action: String
  # @rbs for_param: String
  # @rbs return: void
  def initialize(path:, patch:, action:, for_param: "new")
    @path = path
    @patch = patch
    @action = action
    @for_param = for_param
  end

  # @rbs return: void
  def view_template
    pre(class: "bg-gray-100 p-2 overflow-x-auto",
      data: { controller: "pick-patch-line", patch_path: @path, patch_for: @for_param, action: @action }) do
      code(class: "language-diff") do
        @patch.header.render
      end
      @patch.hunks.each do |hunk|
        code(class: "language-diff") do
          hunk.render
        end
      end
    end
  end
end
