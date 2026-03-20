# frozen_string_literal: true

class Git::DashboardController < ApplicationController
  before_action :add_git_breadcrumb

  def show
    render Views::Git::Dashboard::Show.new
  end
end
