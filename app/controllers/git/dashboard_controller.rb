# frozen_string_literal: true
# rbs_inline: enabled

class Git::DashboardController < ApplicationController
  before_action :add_git_breadcrumb

  # def show: () -> void
  # @rbs return: void
  def show
    render Views::Git::Dashboard::Show.new
  end
end
