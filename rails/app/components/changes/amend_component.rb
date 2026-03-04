# frozen_string_literal: true

class Components::Changes::AmendComponent < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken

  def initialize(unstaged_files:, staged_files:, unstaged_file_path:, staged_file_path:, file_diff:, head_commit_message:, params:)
    @unstaged_files = unstaged_files
    @staged_files = staged_files
    @unstaged_file_path = unstaged_file_path
    @staged_file_path = staged_file_path
    @file_diff = file_diff
    @head_commit_message = head_commit_message
    @params = params
  end

  def view_template
    h1 { plain "Amend Commit" }
    p { a(href: uncommitted_changes_path, class: "changes-link-uncommitted") { plain "Go to Uncommitted Changes" } }

    render(Components::Changes::StagingAreaComponent.new(
      unstaged_files: @unstaged_files,
      staged_files: @staged_files,
      unstaged_file_path: @unstaged_file_path,
      staged_file_path: @staged_file_path,
      file_diff: @file_diff,
      unstaged_link: ->(path) { amend_changes_path(unstaged_file_path: path) },
      staged_link: ->(path) { amend_changes_path(staged_file_path: path) },
      stage_url: stage_changes_path,
      unstage_url: unstage_changes_path,
      stage_label: "Stage this change",
      unstage_label: "Unstage this change",
      stage_amend: true,
      unstage_amend: true
    ))

    form(action: amend_commit_changes_path, method: "post") do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

      div do
        label { plain "Commit message" }
        br
        textarea(name: "commit_message", rows: 3, cols: 60) { plain @head_commit_message }
      end

      div do
        label(for: "no_edit") { plain "No edit" }
        input(type: "checkbox", name: "no_edit", id: "no_edit", value: "1", checked: (@params[:no_edit] == "1"))
      end

      div do
        label(for: "reset_author") { plain "Reset author" }
        input(type: "checkbox", name: "reset_author", id: "reset_author", value: "1", checked: (@params[:reset_author] == "1"))
      end

      button(type: "submit", class: "changes-amend-btn", disabled: @staged_files.empty?) { plain "Amend commit" }
    end
  end
end
