# frozen_string_literal: true

class Components::Tools::FormComponent < Components::Base
  include Phlex::Rails::Helpers::FormAuthenticityToken
  include Phlex::Rails::Helpers::Pluralize

  def initialize(tool:)
    @tool = tool
  end

  def view_template
    form(action: polymorphic_path([@tool]), method: (@tool.persisted? ? "patch" : "post")) do
      input(type: "hidden", name: "authenticity_token", value: form_authenticity_token)

      if @tool.respond_to?(:errors) && @tool.errors.any?
        div(class: "tool__form--errors") do
          h2 { plain "#{pluralize(@tool.errors.count, 'error')} prohibited this tool from being saved:" }
          ul do
            @tool.errors.each do |error|
              li { plain error.full_message }
            end
          end
        end
      end

      div do
        label(for: "tool_name", style: "display: block") { plain "Name" }
        input(type: "text", name: "tool[name]", id: "tool_name", value: @tool.name)
      end

      div do
        label(for: "tool_description", style: "display: block") { plain "Description" }
        input(type: "text", name: "tool[description]", id: "tool_description", value: @tool.description)
      end

      div do
        label(for: "tool_script", style: "display: block") { plain "Script" }
        textarea(name: "tool[script]", id: "tool_script") { plain @tool.script.to_s }
      end

      # Tool parameters area - keep the stimulus container and template markup
      div(id: "tool-parameters", data: { controller: "tool-parameters", "tool-parameters-target" => "container" }) do
        @tool.tool_parameters&.each do |param|
          render Components::Tools::ToolParameterFieldsComponent.new(f_object: param)
        end

        div do
          a(href: "#", data: { action: "tool-parameters#add" }) { plain "Add Parameter" }
        end
      end

      # Template for new parameter - render server-side partial equivalent
      template(id: "tool-parameter-template") do
        render Components::Tools::ToolParameterFieldsComponent.new(f_object: ToolParameter.new, child_index: "NEW_RECORD")
      end

      div do
        button(type: "submit") { plain(@tool.persisted? ? "Update Tool" : "Create Tool") }
      end
    end
  end
end
