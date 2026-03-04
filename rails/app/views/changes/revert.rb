# frozen_string_literal: true

class Views::Changes::Revert < Components::Base
  def view_template
    h1 { plain "Revert Changes" }
    p { plain "Are you sure you want to revert the latest change?" }
    form(action: execute_revert_changes_path, method: "post") do
      input(type: "hidden", name: "authenticity_token", value: view_context.form_authenticity_token)
      button(type: "submit", data: { "confirm" => "Are you sure?" }) { plain "Revert" }
    end
  end
end
