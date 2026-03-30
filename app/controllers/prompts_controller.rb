# frozen_string_literal: true
# rbs_inline: enabled

class PromptsController < ApplicationController
  # @rbs @prompt: Prompt
  # @rbs @index_parameters: Parameters::Prompts::Index
  # @rbs @show_parameters: Parameters::Prompts::Show
  # @rbs @edit_parameters: Parameters::Prompts::Edit
  # @rbs @create_parameters: Parameters::Prompts::Create
  # @rbs @update_parameters: Parameters::Prompts::Update
  # @rbs @destroy_parameters: Parameters::Prompts::Destroy
  # @rbs @run_parameters: Parameters::Prompts::Run

  # @rbs!
  #   def index_parameters: () -> Parameters::Prompts::Index?
  #   def show_parameters: () -> Parameters::Prompts::Show?
  #   def edit_parameters: () -> Parameters::Prompts::Edit?
  #   def create_parameters: () -> Parameters::Prompts::Create?
  #   def update_parameters: () -> Parameters::Prompts::Update?
  #   def destroy_parameters: () -> Parameters::Prompts::Destroy?
  #   def run_parameters: () -> Parameters::Prompts::Run?

  parameters :index, :show, :edit, :create, :update, :destroy, :run

  before_action :add_prompts_breadcrumb
  before_action :add_prompt_breadcrumb, only: %i[show edit run]
  before_action :add_action_breadcrumb, only: %i[edit run]

  # GET /prompts or /prompts.json
  # @rbs return: void
  def index
    parameters = index_parameters || raise(ArgumentError, "Invalid parameters")
    prompts = Kaminari.paginate_array(Prompt.all).page(parameters.page).per(parameters.per_page || 5)
    prompts.each(&:load)
    render Views::Prompts::Index.new(breadcrumbs: breadcrumbs, flash: flash, prompts: prompts)
  end

  # GET /prompts/1 or /prompts/1.json
  # @rbs return: void
  def show
    render Views::Prompts::Show.new(breadcrumbs: breadcrumbs, flash: flash, prompt: prompt)
  end

  # GET /prompts/new
  # @rbs return: void
  def new
    prompt = Prompt.new(id: Prompt.max_id + 1)
    render Views::Prompts::New.new(breadcrumbs: breadcrumbs, flash: flash, prompt: prompt)
  end

  # GET /prompts/1/edit
  # @rbs return: void
  def edit
    render Views::Prompts::Edit.new(breadcrumbs: breadcrumbs, flash: flash, prompt: prompt)
  end

  # POST /prompts or /prompts.json
  # @rbs return: void
  def create
    prompt = Prompt.new(create_parameters.as_json)

    if prompt.save
      redirect_to prompt, notice: "Prompt was successfully created."
    else
      render Views::Prompts::New.new(breadcrumbs: breadcrumbs, flash: flash, prompt: prompt), status: :unprocessable_content
    end
  end

  # PATCH/PUT /prompts/1 or /prompts/1.json
  # @rbs return: void
  def update
    prompt.assign_attributes(update_parameters.as_json.compact)
    if prompt.save
      redirect_to prompt, notice: "Prompt was successfully updated.", status: :see_other
    else
      render Views::Prompts::Edit.new(breadcrumbs: breadcrumbs, flash: flash, prompt: prompt), status: :unprocessable_content
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
    parameters = run_parameters || raise(ArgumentError, "Invalid parameters")
    n = parameters.n
    prompt.run(n)

    redirect_to prompt, notice: "Prompt was successfully run.", status: :see_other
  end

  private

  # @rbs return: Prompt
  def prompt
    return @prompt if @prompt

    member_parameters = show_parameters || edit_parameters || update_parameters || destroy_parameters || run_parameters
    raise(ArgumentError, "Invalid parameters") unless member_parameters

    @prompt = Prompt.find(member_parameters.id)
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
