class ChangesController < ApplicationController
  before_action :set_id, only: [ :show ]

  before_action :add_changes_breadcrumb
  before_action :add_change_breadcrumb, only: [ :show ]
  before_action :add_action_breadcrumb, only: [ :uncommitted ]

  def index
    uncommitted = [ { hash: "uncommitted", author: "", message: "" } ]
    all_commits = uncommitted + Repository.log(10_000)
    @commits = Kaminari.paginate_array(all_commits).page(params[:page]).per(10)
  end

  def revert
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
  end

  def show
    @file_diffs = Repository.tracked_diffs(@id)
    @commit_message = Repository.commit_message(@id)
    @file_paths = @file_diffs.map { |fd| fd[0] }
    if params[:file_path]
      @selected_file_path = params[:file_path]
      @file_diff = @file_diffs.find { |fd| fd[0] == params[:file_path] }
    end
  end

  def stage
    if params[:file_path].present?
      Repository.stage_file(params[:file_path])
    end
    redirect_to uncommitted_changes_path
  end

  def unstage
    if params[:file_path].present?
      Repository.unstage_file(params[:file_path])
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
