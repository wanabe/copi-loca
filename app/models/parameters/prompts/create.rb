# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Prompts::Create < Parameters::Prompts::Update
  private

  # @rbs params: ActionController::Parameters
  # @rbs return: ActionController::Parameters
  def permitted_params(params)
    params.require(:prompt).permit(%i[id name description text])
  end
end
