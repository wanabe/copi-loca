# frozen_string_literal: true

module Views
  module Changes
    class Show < Components::Base
      def initialize(id:, can_start_rebase:, commit_info:, commit_message:, file_paths:, selected_file_path: nil, file_diff: nil)
        @id = id
        @can_start_rebase = can_start_rebase
        @commit_info = commit_info
        @commit_message = commit_message
        @file_paths = file_paths
        @selected_file_path = selected_file_path
        @file_diff = file_diff
      end

      def view_template
        h1 do
          plain "Commit "
          plain ERB::Util.html_escape(@id)
          plain " Changes"
        end

        p do
          a(href: rebase_index_path(base: @id), class: "btn btn-primary") { plain "Rebase from this commit" } if @can_start_rebase
        end

        p do
          strong { plain "Author:" }
          plain " "
          plain ERB::Util.html_escape(@commit_info[:author])
          br
          strong { plain "Author Date:" }
          plain " "
          plain ERB::Util.html_escape(@commit_info[:author_date])
          br
          strong { plain "Commit Date:" }
          plain " "
          plain ERB::Util.html_escape(@commit_info[:commit_date])
        end

        pre { plain ERB::Util.html_escape(@commit_message) }

        ul do
          (@file_paths || []).each do |file|
            selected = (file == @selected_file_path)
            li(class: "changes-list__item#{' changes-list__item--selected' if selected}") do
              a(href: change_path(@id, file_path: file)) { plain file }
            end
          end
        end

        return unless @file_diff

        hr
        render Components::Changes::DiffComponent.new(file_diffs: [@file_diff], stage_state: nil, stage_url: nil, unstage_url: nil,
          stage_amend: nil, unstage_amend: nil)
      end
    end
  end
end
