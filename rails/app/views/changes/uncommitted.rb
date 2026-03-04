# frozen_string_literal: true

class Views::Changes::Uncommitted < Views::Base
  def initialize(unstaged_files:, staged_files:, unstaged_file_path: nil, staged_file_path: nil, file_diff: nil)
    @unstaged_files = unstaged_files
    @staged_files = staged_files
    @unstaged_file_path = unstaged_file_path
    @staged_file_path = staged_file_path
    @file_diff = file_diff
  end

  def view_template
    h1 { plain "Uncommitted" }
    p { a(href: amend_changes_path, class: "changes-link-amend") { plain "Go to Amend Commit" } }

    render Components::Changes::StagingAreaComponent.new(
      unstaged_files: @unstaged_files,
      staged_files: @staged_files,
      unstaged_file_path: @unstaged_file_path,
      staged_file_path: @staged_file_path,
      file_diff: @file_diff,
      unstaged_link: ->(path) { uncommitted_changes_path(unstaged_file_path: path) },
      staged_link: ->(path) { uncommitted_changes_path(staged_file_path: path) },
      stage_url: stage_changes_path,
      unstage_url: unstage_changes_path,
      stage_label: "Stage this change",
      unstage_label: "Unstage this change",
      stage_amend: false,
      unstage_amend: false
    )

    form(action: commit_changes_path, method: "post") do
      input(type: "hidden", name: "authenticity_token", value: view_context.form_authenticity_token)

      div do
        label { plain "Commit message" }
        br
        textarea(name: "commit_message", rows: 3, cols: 60) { plain "" }
      end

      button(type: "submit") { plain "Commit" }
    end
  end
end
