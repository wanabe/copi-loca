# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Prompts::Update < Parameters::Prompts::Show
  # @rbs!
  #   attr_accessor name(): String
  #   attr_accessor description(): String
  #   attr_accessor text(): String

  attribute :name, :string
  attribute :description, :string
  attribute :text, :string

  private

  # @rbs params: ActionController::Parameters
  # @rbs return: ActionController::Parameters
  def permitted_params(params)
    params.permit(:id).merge(params.require(:prompt).permit(%i[name description text]))
  end
end
