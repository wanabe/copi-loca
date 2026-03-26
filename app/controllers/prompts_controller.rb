# frozen_string_literal: true
# rbs_inline: enabled

class PromptsController < ApplicationController
  # @rbs @prompt: Prompt
  # @rbs @prompt_parameters: Parameters::Prompts::Prompt

  before_action :add_prompts_breadcrumb
  before_action :add_prompt_breadcrumb, only: %i[show edit run]
  before_action :add_action_breadcrumb, only: %i[edit run]

  # GET /prompts or /prompts.json
  # @rbs return: void
  def index
    parameters = Parameters::Index.new(**params.permit(:page, :per_page))
    prompts = Kaminari.paginate_array(Prompt.all).page(parameters.page).per(parameters.per_page || 5)
    prompts.each(&:load)
    render Views::Prompts::Index.new(prompts: prompts)
  end

  # GET /prompts/1 or /prompts/1.json
  # @rbs return: void
  def show
    render Views::Prompts::Show.new(prompt: prompt)
  end

  # GET /prompts/new
  # @rbs return: void
  def new
    prompt = Prompt.new(id: Prompt.max_id + 1)
    render Views::Prompts::New.new(prompt: prompt)
  end

  # GET /prompts/1/edit
  # @rbs return: void
  def edit
    render Views::Prompts::Edit.new(prompt: prompt)
  end

  # POST /prompts or /prompts.json
  # @rbs return: void
  def create
    prompt = Prompt.new(prompt_parameters.as_json)

    if prompt.save
      redirect_to prompt, notice: "Prompt was successfully created."
    else
      render Views::Prompts::New.new(prompt: prompt), status: :unprocessable_content
    end
  end

  # PATCH/PUT /prompts/1 or /prompts/1.json
  # @rbs return: void
  def update
    prompt.assign_attributes(prompt_parameters.as_json.compact)
    if prompt.save
      redirect_to prompt, notice: "Prompt was successfully updated.", status: :see_other
    else
      render Views::Prompts::Edit.new(prompt: prompt), status: :unprocessable_content
    end
  end

  # DELETE /prompts/1 or /prompts/1.json
  # @rbs return: void
  def destroy
    prompt.destroy!

    redirect_to prompts_path, notice: "Prompt was successfully destroyed.", status: :see_other
  end

  # @rbs return: void
  def run
    parameters = Parameters::Prompts::Run.new(**params.permit(:id, :n))
    n = parameters.n
    prompt.run(n)

    redirect_to prompt, notice: "Prompt was successfully run.", status: :see_other
  end

  private

  # @rbs return: Prompt
  def prompt
    return @prompt if @prompt

    member_parameters = Parameters::Member.new(**params.permit(:id))
    @prompt = Prompt.find(member_parameters.id)
  end

  # @rbs return: Parameters::Prompts::Prompt
  def prompt_parameters
    return @prompt_parameters if @prompt_parameters

    prompt_params = params.expect(prompt: %i[id name description text])
    @prompt_parameters = Parameters::Prompts::Prompt.new(**prompt_params)
  end

  # @rbs return: void
  def add_prompts_breadcrumb
    add_breadcrumb("Prompts", prompts_path)
  end

  # @rbs return: void
  def add_prompt_breadcrumb
    add_breadcrumb("#{prompt.id}(#{prompt.name})", prompt_path(prompt))
  end
end
