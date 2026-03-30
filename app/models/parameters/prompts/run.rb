# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Prompts::Run < Parameters::Prompts::Show
  # @rbs!
  #   attr_accessor n(): Integer

  attribute :n, :integer, default: 1

  private

  # @rbs params: ActionController::Parameters
  # @rbs return: ActionController::Parameters
  def permitted_params(params)
    params.permit(:id, :n)
  end
end
