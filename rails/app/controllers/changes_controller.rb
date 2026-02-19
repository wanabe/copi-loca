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
    @file_diffs = Repository.uncommitted_diffs
  end

  def show
    @file_diffs = Repository.tracked_diffs(@id)
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
