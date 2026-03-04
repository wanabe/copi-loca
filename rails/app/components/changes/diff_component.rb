# frozen_string_literal: true

class Components::Changes::DiffComponent < Components::Base
  include ERB::Util

  def initialize(file_diffs:, stage_state: nil, stage_url: nil, unstage_url: nil, stage_amend: nil, unstage_amend: nil)
    @file_diffs = file_diffs
    @stage_state = stage_state
    @stage_url = stage_url
    @unstage_url = unstage_url
    @stage_amend = stage_amend
    @unstage_amend = unstage_amend
  end

  def view_template
    @file_diffs.each do |path, diff|
      h2(class: "changes-diff__file-path") do
        a(href: file_path(path)) { plain path }
      end

      if @stage_state.nil?
        pre do
          code(class: "language-diff") { plain ERB::Util.html_escape(diff) }
        end
      else
        pre do
          code(class: "language-diff",
            data: {
              controller: "diff-line-click",
              "diff-line-click-target": "code",
              file_path: path,
              stage_state: @stage_state,
              stage_url: @stage_url,
              unstage_url: @unstage_url,
              amend: @stage_amend || @unstage_amend ? "true" : "false"
            }) { plain ERB::Util.html_escape(diff) }
        end
      end
    end
  end
end
