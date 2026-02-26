class RebaseController < ApplicationController
  before_action :add_rebase_breadcrumb
  before_action :add_action_breadcrumb, only: [ :start, :continue ]

  def index
    @rebase_status = Repository.rebase_status
    onto = @rebase_status&.[](:onto)
    if @rebase_status && onto
      @base = onto.chomp
      @all_commits = Repository.log_for_rebase(range: "#{onto}~..#{onto}", limit: 1)
      @rebase_logs = []
    else
      @all_commits = Repository.log_for_rebase
      if @all_commits.any?
        @base = params[:base].presence || @all_commits.last[:hash]
        @rebase_logs = Repository.log_for_rebase(base: @base)
      else
        @base = nil
        @rebase_logs = []
      end
    end
  end

  def start
    steps = params[:rebase_steps]&.map { |s| { hash: s[:hash], action: s[:action] } } || []
    base = params[:base]

    Repository.rebase_i(steps, base)
    redirect_to rebase_index_path, notice: "Rebase completed."
  end

  def continue
    Dir.chdir(Repository::DEFAULT_PATH) do
      success = system("git rebase --continue")
      if success
        redirect_to rebase_index_path, notice: "Rebase continued."
      else
        redirect_to rebase_index_path, alert: "Rebase continue failed."
      end
    end
  end

  private

  def add_rebase_breadcrumb
    add_breadcrumb("Rebase", rebase_index_path)
  end
end
