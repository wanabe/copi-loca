# frozen_string_literal: true
# rbs_inline: enabled

class HomeController < ApplicationController
  # GET /
  # def index: () -> void
  # @rbs return: void
  def index
    render Views::Home::Index.new(breadcrumbs: breadcrumbs, flash: flash)
  end
end
