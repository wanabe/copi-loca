class AppOpsController < ApplicationController
  def index
  end

  def confirm
    @op_key = params[:op]
    allowed_ops = %w[bundle_install rspec]
    unless allowed_ops.include?(@op_key)
      redirect_to app_ops_path, alert: 'Unknown operation.'
      return
    end
    @partial_name = @op_key
  end

  def bundle_install
    @output, @status = Repository.run_command('bundle install')
    render :result
  end

  def rspec
    @output, @status = Repository.run_command('bundle exec rspec')
    render :result
  end
end
