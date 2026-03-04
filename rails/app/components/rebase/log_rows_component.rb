# frozen_string_literal: true

module Components
  module Rebase
    class LogRowsComponent < Components::Base
      ACTIONS = %w[pick edit squash fixup reword drop break].freeze

      def initialize(logs:, disabled: false, name_prefix: nil)
        @logs = logs
        @disabled = disabled
        @name_prefix = name_prefix
      end

      def view_template
        @logs.each_with_index do |log, idx|
          tr(class: "rebase__row") do
            td do
              if @name_prefix
                input(type: "hidden", name: "#{@name_prefix}[][hash]", value: log[:hash], disabled: @disabled)
              else
                input(type: "hidden", name: nil, value: log[:hash], disabled: @disabled)
              end

              select(name: (@name_prefix ? "#{@name_prefix}[][action]" : nil), disabled: @disabled) do
                ACTIONS.each do |opt|
                  option(value: opt, selected: (opt == log[:action])) { plain opt }
                end
              end

              if @disabled
                button(type: "button", disabled: true) { plain "\u2191" }
                button(type: "button", disabled: true) { plain "\u2193" }
              else
                button(type: "button", data: { action: "click->rebase-order#move", direction: -1 }, disabled: idx.zero?) { plain "\u2191" }
                button(type: "button", data: { action: "click->rebase-order#move", direction: 1 }, disabled: (idx == @logs.size - 1)) do
                  plain "\u2193"
                end
              end
            end
            td { plain(log[:hash] && log[:hash][0, 7]) }
            td { plain log[:message] }
          end
        end
      end
    end
  end
end
