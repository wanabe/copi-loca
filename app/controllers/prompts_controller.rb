# frozen_string_literal: true

class PromptsController < ApplicationController
  before_action :set_prompt, only: %i[show edit update destroy run]

  # GET /prompts or /prompts.json
  def index
    @prompts = Prompt.all
    render Views::Prompts::Index.new(prompts: @prompts, notice: flash[:notice])
  end

  # GET /prompts/1 or /prompts/1.json
  def show
    render Views::Prompts::Show.new(prompt: @prompt, notice: flash[:notice])
  end

  # GET /prompts/new
  def new
    @prompt = Prompt.new(id: Prompt.max_id + 1)
    render Views::Prompts::New.new(prompt: @prompt)
  end

  # GET /prompts/1/edit
  def edit
    render Views::Prompts::Edit.new(prompt: @prompt)
  end

  # POST /prompts or /prompts.json
  def create
    @prompt = Prompt.new(prompt_params)

    respond_to do |format|
      if @prompt.save
        format.html { redirect_to @prompt, notice: "Prompt was successfully created." }
        format.json { render :show, status: :created, location: @prompt }
      else
        format.html { render :new, status: :unprocessable_content }
        format.json { render json: @prompt.errors, status: :unprocessable_content }
      end
    end
  end

  # PATCH/PUT /prompts/1 or /prompts/1.json
  def update
    @prompt.assign_attributes(prompt_params)
    respond_to do |format|
      if @prompt.save
        format.html { redirect_to @prompt, notice: "Prompt was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @prompt }
      else
        format.html { render :edit, status: :unprocessable_content }
        format.json { render json: @prompt.errors, status: :unprocessable_content }
      end
    end
  end

  # DELETE /prompts/1 or /prompts/1.json
  def destroy
    @prompt.destroy!

    respond_to do |format|
      format.html { redirect_to prompts_path, notice: "Prompt was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  def run
    @prompt.run
    respond_to do |format|
      format.html { redirect_to @prompt, notice: "Prompt was successfully run.", status: :see_other }
      format.json { render :show, status: :ok, location: @prompt }
    end
  end

  private

  # Use callbacks to share common setup or constraints between actions.
  def set_prompt
    @prompt = Prompt.find(params.expect(:id))
  end

  # Only allow a list of trusted parameters through.
  def prompt_params
    params.expect(prompt: %i[id text])
  end
end
