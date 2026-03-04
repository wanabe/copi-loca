# frozen_string_literal: true

class Components::CustomAgents::CustomAgentComponent < Components::Base
  include Phlex::Rails::Helpers::DOMID

  def initialize(custom_agent:)
    @custom_agent = custom_agent
  end

  def view_template
    div id: dom_id(@custom_agent) do
      div do
        strong { plain "Name:" }
        plain " "
        plain @custom_agent.name
      end

      div do
        strong { plain "Display name:" }
        plain " "
        plain @custom_agent.display_name
      end

      div do
        strong { plain "Description:" }
        plain " "
        plain @custom_agent.description
      end

      div do
        strong { plain "Prompt:" }
        plain " "
        plain @custom_agent.prompt
      end
    end
  end
end
