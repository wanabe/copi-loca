class ChangesController < ApplicationController
  def uncommitted
    @file_diffs = Repository.uncommitted_diffs
  end
  def index
    uncommitted = [{ hash: 'uncommitted', author: '', message: '' }]
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

  def show
    id = params[:id]
    @file_diffs = Repository.tracked_diffs(id)
  end
end
