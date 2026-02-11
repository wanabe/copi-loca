class ModelsController < ApplicationController
  def index
    @models = Client.new.available_models
    @open_id = params[:id]
  end
end
