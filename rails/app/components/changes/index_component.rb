# frozen_string_literal: true

module Components
  module Changes
    class IndexComponent < Components::Base
      def initialize(current_branch:, rebase_status:, commits:)
        @current_branch = current_branch
        @rebase_status = rebase_status
        @commits = commits
      end

      def view_template
        h1 { plain "Changes" }
        p do
          plain "Current branch: "
          span(class: "changes__branch-label") { plain @current_branch }
          if @rebase_status
            plain " ("
            span(class: "changes__branch-label") { plain @rebase_status[:head].sub(%r{^refs/heads/}, "") }
            plain " "
            a(href: rebase_index_path) { plain "rebasing" }
            plain ")"
          end
        end

        ul(class: "changes-list") do
          @commits.each do |commit|
            li(class: "changes-list__item") do
              strong { plain "Hash:" }
              plain " "
              href = if commit[:hash] == "uncommitted"
                       uncommitted_changes_path
                     else
                       change_path(commit[:hash])
                     end
              a(href: href) { plain commit[:hash] }
              br
              strong { plain "Author:" }
              plain " "
              plain commit[:author]
              br
              strong { plain "Message:" }
              plain " "
              plain commit[:message]
            end
          end
        end

        render Components::Pagination::PaginationComponent.new(collection: @commits)
      end
    end
  end
end
