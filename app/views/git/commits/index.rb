# frozen_string_literal: true
# rbs_inline: enabled

class Views::Git::Commits::Index < Views::Base
  # @rbs @ref: String
  # @rbs @commits: Kaminari::PaginatableArray[Git::Log::Commit]

  # @rbs ref: String
  # @rbs commits: Kaminari::PaginatableArray[Git::Log::Commit]
  # @rbs return: void
  def initialize(ref:, commits:)
    @ref = ref
    @commits = commits
  end

  # @rbs return: void
  def view_template
    h1(class: "text-2xl font-bold mb-4") { "Git Commits on #{@ref}" }
    ul(class: "space-y-2") do
      @commits.each do |commit|
        li(class: "p-4 border rounded") do
          h2(class: "text-lg font-semibold") { commit.message }
          ul(class: "text-sm text-gray-600") do
            li { "Commit Hash: #{commit.commit_hash}" }
            li { "Author: #{commit.author_name} <#{commit.author_email}>" }
            li { "Author Date: #{commit.author_date}" }
            li { "Commit Date: #{commit.committer_date}" }
          end
        end
      end
      render Components::Paginator.new(items: @commits)
    end
  end
end
