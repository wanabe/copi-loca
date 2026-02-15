class ModelsController < ApplicationController
  before_action :add_models_breadcrumb

  def index
    @models = Client.new.available_models
    @open_id = params[:id]
  end

  private
    def add_models_breadcrumb
      add_breadcrumb("Models", models_path)
    end
end
