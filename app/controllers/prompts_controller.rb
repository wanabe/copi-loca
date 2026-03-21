# frozen_string_literal: true
# rbs_inline: enabled

class PromptsController < ApplicationController
  before_action :set_prompt, only: %i[show edit update destroy run]
  before_action :add_prompts_breadcrumb
  before_action :add_prompt_breadcrumb, only: %i[show edit run]
  before_action :add_action_breadcrumb, only: %i[edit run]

  # GET /prompts or /prompts.json
  # @rbs return: void
  def index
    # @rbs @prompts: Kaminari::PaginatableArray[Prompt]

    @prompts = Kaminari.paginate_array(Prompt.all).page(params[:page]).per(params[:per_page] || 5)
    @prompts.each(&:load)
    render Views::Prompts::Index.new(prompts: @prompts, notice: flash[:notice])
  end

  # GET /prompts/1 or /prompts/1.json
  # @rbs return: void
  def show
    render Views::Prompts::Show.new(prompt: @prompt, notice: flash[:notice])
  end

  # GET /prompts/new
  # @rbs return: void
  def new
    @prompt = Prompt.new(id: Prompt.max_id + 1)
    render Views::Prompts::New.new(prompt: @prompt)
  end

  # GET /prompts/1/edit
  # @rbs return: void
  def edit
    render Views::Prompts::Edit.new(prompt: @prompt)
  end

  # POST /prompts or /prompts.json
  # @rbs return: void
  def create
    # @rbs @prompt: Prompt

    @prompt = Prompt.new(prompt_params)

    respond_to do |format|
      if @prompt.save
        format.html { redirect_to @prompt, notice: "Prompt was successfully created." }
        format.json { render :show, status: :created, location: @prompt }
      else
        format.html { render Views::Prompts::New.new(prompt: @prompt), status: :unprocessable_content }
        format.json { render json: @prompt.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /prompts/1 or /prompts/1.json
  # @rbs return: void
  def update
    @prompt.assign_attributes(prompt_params)
    respond_to do |format|
      if @prompt.save
        format.html { redirect_to @prompt, notice: "Prompt was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @prompt }
      else
        format.html { render Views::Prompts::Edit.new(prompt: @prompt), status: :unprocessable_content }
        format.json { render json: @prompt.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /prompts/1 or /prompts/1.json
  # @rbs return: void
  def destroy
    @prompt.destroy!

    respond_to do |format|
      format.html { redirect_to prompts_path, notice: "Prompt was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  # @rbs return: void
  def run
    n = params[:n].to_i
    n = 1 if n <= 0
    @prompt.run(n)
    respond_to do |format|
      format.html { redirect_to @prompt, notice: "Prompt was successfully run.", status: :see_other }
      format.json { render :show, status: :ok, location: @prompt }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  # @rbs return: void
  def set_prompt
    @prompt = Prompt.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  # @rbs return: untyped
  def prompt_params
    params.expect(prompt: %i[id text name description])
  end

  # @rbs return: void
  def add_prompts_breadcrumb
    add_breadcrumb("Prompts", prompts_path)
  end

  # @rbs return: void
  def add_prompt_breadcrumb
    add_breadcrumb("#{@prompt.id}(#{@prompt.name})", prompt_path(@prompt))
  end
end
