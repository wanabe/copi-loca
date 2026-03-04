# frozen_string_literal: true

class ChangesController < ApplicationController
  before_action :set_id, only: [:show]

  before_action :add_changes_breadcrumb
  before_action :add_change_breadcrumb, only: [:show]
  before_action :add_action_breadcrumb, only: %i[uncommitted amend]

  def index
    uncommitted = [{ hash: "uncommitted", author: "", message: "" }]
    all_commits = uncommitted + Repository.log(10_000)
    commits = Kaminari.paginate_array(all_commits).page(params[:page]).per(10)
    current_branch = Repository.current_branch
    rebase_status = Repository.rebase_status

    render Views::Changes::Index.new(
      current_branch: current_branch,
      rebase_status: rebase_status,
      commits: commits
    )
  end

  def revert
    render Views::Changes::Revert.new
  end

  def execute_revert
    client = Client.instance.copilot_client
    client.create_session(model: "gpt-4.1") do |session|
      session.send("Please execute `git checkout . && git clean -fd`")
      client.wait { session.idle? }
    end

    redirect_to root_path, notice: "Code changes reverted."
  end

  def uncommitted
    staged_diffs = Repository.staged_diffs
    unstaged_diffs = Repository.unstaged_diffs
    @staged_files = staged_diffs.map(&:first)
    @unstaged_files = unstaged_diffs.map(&:first)
    if params[:staged_file_path]
      @staged_file_path = params[:staged_file_path]
      @file_diff = staged_diffs.find { |fd| fd[0] == params[:staged_file_path] }
    elsif params[:unstaged_file_path]
      @unstaged_file_path = params[:unstaged_file_path]
      @file_diff = unstaged_diffs.find { |fd| fd[0] == params[:unstaged_file_path] }
    end

    render Views::Changes::Uncommitted.new(
      unstaged_files: @unstaged_files,
      staged_files: @staged_files,
      unstaged_file_path: @unstaged_file_path,
      staged_file_path: @staged_file_path,
      file_diff: @file_diff
    )
  end

  def show
    @file_diffs = Repository.tracked_diffs(@id)
    @commit_message = Repository.commit_message(@id)
    @commit_info = Repository.commit_info(@id)
    @file_paths = @file_diffs.pluck(0)
    @can_start_rebase = Repository.can_start_rebase?
    if params[:file_path]
      @selected_file_path = params[:file_path]
      @file_diff = @file_diffs.find { |fd| fd[0] == params[:file_path] }
    end

    render Views::Changes::Show.new(
      id: @id,
      can_start_rebase: @can_start_rebase,
      commit_info: @commit_info,
      commit_message: @commit_message,
      file_paths: @file_paths,
      selected_file_path: @selected_file_path,
      file_diff: @file_diff
    )
  end

  def stage
    if params[:file_path].blank?
      if params[:amend]
        redirect_back_or_to(amend_changes_path, alert: "File path is required to stage changes.")
      else
        redirect_back_or_to(uncommitted_changes_path, alert: "File path is required to stage changes.")
      end
      return
    end

    line_number = params[:line_number]&.to_i
    if line_number
      Repository.stage_line(params[:file_path], line_number)
      if params[:amend]
        redirect_to amend_changes_path(unstaged_file_path: params[:file_path])
      else
        redirect_to uncommitted_changes_path(unstaged_file_path: params[:file_path])
      end
    else
      Repository.stage_file(params[:file_path])
      if params[:amend]
        redirect_to amend_changes_path(staged_file_path: params[:file_path])
      else
        redirect_to uncommitted_changes_path(staged_file_path: params[:file_path])
      end
    end
  end

  def unstage
    if params[:file_path].blank?
      if params[:amend]
        redirect_back_or_to(amend_changes_path, alert: "File path is required to unstage changes.")
      else
        redirect_back_or_to(uncommitted_changes_path, alert: "File path is required to unstage changes.")
      end
      return
    end

    line_number = params[:line_number]&.to_i
    if line_number
      Repository.unstage_line(params[:file_path], line_number, amend: !!params[:amend])
      if params[:amend]
        redirect_to amend_changes_path(staged_file_path: params[:file_path])
      else
        redirect_to uncommitted_changes_path(staged_file_path: params[:file_path])
      end
    else
      Repository.unstage_file(params[:file_path], amend: !!params[:amend])
      if params[:amend]
        redirect_to amend_changes_path(unstaged_file_path: params[:file_path])
      else
        redirect_to uncommitted_changes_path(unstaged_file_path: params[:file_path])
      end
    end
  end

  def commit
    Repository.commit(params[:commit_message]) if params[:commit_message].present?
    redirect_to uncommitted_changes_path
  end

  def amend
    staged_diffs = Repository.amend_diffs
    unstaged_diffs = Repository.unstaged_diffs
    @staged_files = staged_diffs.map(&:first)
    @unstaged_files = unstaged_diffs.map(&:first)
    @head_commit_message = Repository.head_commit_message
    if params[:staged_file_path]
      @staged_file_path = params[:staged_file_path]
      @file_diff = staged_diffs.find { |fd| fd[0] == params[:staged_file_path] }
    elsif params[:unstaged_file_path]
      @unstaged_file_path = params[:unstaged_file_path]
      @file_diff = unstaged_diffs.find { |fd| fd[0] == params[:unstaged_file_path] }
    end

    # Explicitly render the Phlex view and pass params so the view can access them
    render Views::Changes::Amend.new(
      unstaged_files: @unstaged_files,
      staged_files: @staged_files,
      unstaged_file_path: @unstaged_file_path,
      staged_file_path: @staged_file_path,
      file_diff: @file_diff,
      head_commit_message: @head_commit_message,
      params: params
    )
  end

  def amend_commit
    reset_author = params[:reset_author] == "1"
    if params[:no_edit] == "1"
      Repository.amend_no_edit(reset_author: reset_author)
    else
      Repository.amend_with_message(params[:commit_message], reset_author: reset_author)
    end
    redirect_to uncommitted_changes_path
  end

  private

  def set_id
    @id = params[:id]
  end

  def add_changes_breadcrumb
    add_breadcrumb("Changes", changes_path)
  end

  def add_change_breadcrumb
    add_breadcrumb(@id, change_path(@id))
  end
end
