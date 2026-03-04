# frozen_string_literal: true

class Views::Changes::Index < Components::Base
  def initialize(current_branch:, rebase_status:, commits:)
    @current_branch = current_branch
    @rebase_status = rebase_status
    @commits = commits
  end

  def view_template
    render Components::Changes::IndexComponent.new(current_branch: @current_branch, rebase_status: @rebase_status, commits: @commits)
  end
end
