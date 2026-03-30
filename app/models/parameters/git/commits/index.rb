# frozen_string_literal: true
# rbs_inline: enabled

class Parameters::Git::Commits::Index < Parameters::Index
  # @rbs!
  #   attr_accessor ref(): String

  attribute :ref, :string

  private

  # @rbs params: ActionController::Parameters
  # @rbs return: ActionController::Parameters
  def permitted_params(params)
    params.permit(:ref, :page, :per_page)
  end
end
