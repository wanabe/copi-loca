# frozen_string_literal: true

class Views::Changes::Amend < Components::Base
  def initialize(unstaged_files:, staged_files:, unstaged_file_path: nil, staged_file_path: nil, file_diff: nil, head_commit_message: nil,
                 params: nil)
    @unstaged_files = unstaged_files
    @staged_files = staged_files
    @unstaged_file_path = unstaged_file_path
    @staged_file_path = staged_file_path
    @file_diff = file_diff
    @head_commit_message = head_commit_message
    @params = params
  end

  def view_template
    render Components::Changes::AmendComponent.new(unstaged_files: @unstaged_files, staged_files: @staged_files,
      unstaged_file_path: @unstaged_file_path, staged_file_path: @staged_file_path,
      file_diff: @file_diff, head_commit_message: @head_commit_message, params: @params)
  end
end
