# frozen_string_literal: true

class Views::Rebase::Index < Components::Base
  def initialize(all_commits:, base:, rebase_status:, rebase_logs:, can_start_rebase:, can_continue_rebase:)
    @all_commits = all_commits
    @base = base
    @rebase_status = rebase_status
    @rebase_logs = rebase_logs
    @can_start_rebase = can_start_rebase
    @can_continue_rebase = can_continue_rebase
  end

  def view_template
    h2 { plain "Rebase" }

    form(action: rebase_index_path, method: "get", id: "base-select-form", data: { controller: "rebase" }) do
      label do
        plain "Base commit:"
        select(name: :base, data: { action: "change->rebase#submit" }, disabled: @rebase_status.present?) do
          @all_commits.each do |c|
            option(value: c[:hash], selected: (c[:hash] == @base)) { plain "#{c[:hash][0, 7]}: #{c[:message]}" }
          end
        end
      end
    end

    form(action: start_rebase_index_path, method: "post", data: { turbo: false }) do
      input(type: "hidden", name: :base, value: @base)

      table(data: { controller: "rebase-order", "rebase-order-disabled-value": @rebase_status.present? }) do
        thead do
          tr do
            th { plain "Select" }
            th { plain "Commit Hash" }
            th { plain "Message" }
          end
        end
        tbody do
          render Components::Rebase::LogRowsComponent.new(logs: @rebase_logs, disabled: false, name_prefix: "rebase_steps")
          if @rebase_status
            render Components::Rebase::LogRowsComponent.new(logs: @rebase_status[:done], disabled: true, name_prefix: nil)
            tr do
              td(colspan: 3, class: "rebase__current-row") { plain "< Current >" }
            end
            render Components::Rebase::LogRowsComponent.new(logs: @rebase_status[:todo], disabled: true, name_prefix: nil)
          end
        end
      end

      button(type: "submit", disabled: !@can_start_rebase) { plain "Start Rebase" } unless @rebase_status
    end

    return unless @rebase_status

    form(action: continue_rebase_index_path, method: "post", class: "inline") do
      input(type: "hidden", name: "authenticity_token", value: view_context.form_authenticity_token)
      button(type: "submit", disabled: !@can_continue_rebase) { plain "Rebase Continue" }
    end
  end
end
