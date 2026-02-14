class AppOpsController < ApplicationController
  def index
  end

  def confirm
    @op_key = params[:op]
    unless %w[bundle_install].include?(@op_key)
      redirect_to app_ops_path, alert: 'Unknown operation.'
      return
    end
  end

  def bundle_install
    @output, @status = Repository.run_command('bundle install')
    render :result
  end
end
