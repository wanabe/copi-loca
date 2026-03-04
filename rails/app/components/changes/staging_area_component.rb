# frozen_string_literal: true

class Components::Changes::StagingAreaComponent < Components::Base
  include ERB::Util
  include Phlex::Rails::Helpers::FormAuthenticityToken

  def initialize(unstaged_files:, staged_files:, unstaged_file_path:, staged_file_path:, file_diff:, unstaged_link:, staged_link:, stage_url:,
                 unstage_url:, stage_label:, unstage_label:, stage_amend:, unstage_amend:)
    @unstaged_files = unstaged_files
    @staged_files = staged_files
    @unstaged_file_path = unstaged_file_path
    @staged_file_path = staged_file_path
    @file_diff = file_diff
    @unstaged_link = unstaged_link
    @staged_link = staged_link
    @stage_url = stage_url
    @unstage_url = unstage_url
    @stage_label = stage_label
    @unstage_label = unstage_label
    @stage_amend = stage_amend
    @unstage_amend = unstage_amend
  end

  def view_template
    h2 { plain "Unstaged Changes" }
    ul do
      @unstaged_files.each do |path|
        selected = (path == @unstaged_file_path)
        li(class: "staging-list__item#{' changes-list__item--selected' if selected}") do
          form(action: @stage_url, method: "post", class: "inline-form") do
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
            input(type: "hidden", name: "file_path", value: path)
            input(type: "hidden", name: "amend", value: true) if @stage_amend
            button(type: "submit", title: "Stage this change", class: "changes-stage-btn") { plain "\u2193" }
          end
          a(href: @unstaged_link.call(path)) { plain html_escape(path) }
        end
      end
    end

    h2 { plain "Staged Changes" }
    ul do
      @staged_files.each do |path|
        selected = (path == @staged_file_path)
        li(class: "staging-list__item#{' changes-list__item--selected' if selected}") do
          form(action: @unstage_url, method: "post", class: "inline-form") do
            input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
            input(type: "hidden", name: "file_path", value: path)
            input(type: "hidden", name: "amend", value: true) if @unstage_amend
            button(type: "submit", title: "Unstage this change", class: "changes-unstage-btn") { plain "\u2191" }
          end
          a(href: @staged_link.call(path)) { plain html_escape(path) }
        end
      end
    end

    return unless @file_diff

    hr
    if @unstaged_file_path
      form(action: @stage_url, method: "post") do
        input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
        input(type: "hidden", name: "file_path", value: @unstaged_file_path)
        input(type: "hidden", name: "amend", value: true) if @stage_amend
        button(type: "submit", class: "changes-stage-btn") { plain @stage_label }
      end
    elsif @staged_file_path
      form(action: @unstage_url, method: "post") do
        input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)
        input(type: "hidden", name: "file_path", value: @staged_file_path)
        input(type: "hidden", name: "amend", value: true) if @unstage_amend
        button(type: "submit", class: "changes-unstage-btn") { plain @unstage_label }
      end
    end

    render Components::Changes::DiffComponent.new(file_diffs: [@file_diff], stage_state: (@unstaged_file_path ? "unstaged" : "staged"),
      stage_url: @stage_url, unstage_url: @unstage_url, stage_amend: @stage_amend, unstage_amend: @unstage_amend)
  end
end
