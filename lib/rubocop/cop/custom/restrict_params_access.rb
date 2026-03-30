# frozen_string_literal: true
# rbs_inline: enabled

require "rubocop"

module RuboCop
  module Cop
    module Custom
      class RestrictParamsAccess < Base
        MSG = "Direct access to `params` is prohibited. " \
              "Use a Parameter Model and wrap it in a method that ends with `parameters` (e.g., `show_parameters`)."

        # @rbs!
        #   def params_call?: (RuboCop::AST::SendNode) -> bool

        # Detects calls to the `params` method with no receiver or with `self` as the receiver
        def_node_matcher :params_call?, <<~PATTERN
          (send {nil? self} :params)
        PATTERN

        # @rbs node: RuboCop::AST::SendNode
        # @rbs return: void
        def on_send(node)
          return unless params_call?(node)
          return if allowed_method_context?(node)

          add_offense(node)
        end

        private

        # @rbs node: RuboCop::AST::SendNode
        # @rbs return: bool
        def allowed_method_context?(node)
          def_node = def_node(node)
          return false unless def_node

          method_name = def_node.method_name.to_s
          method_name.end_with?("parameters")
        end

        # @rbs node: RuboCop::AST::SendNode
        # @rbs return: RuboCop::AST::DefNode | nil
        def def_node(node)
          def_node = node.each_ancestor(:def, :defs).first
          return nil unless def_node.is_a?(RuboCop::AST::DefNode)

          def_node
        end
      end
    end
  end
end

# for rbs_rails
Rubocop::Cop::Custom::RestrictParamsAccess = RuboCop::Cop::Custom::RestrictParamsAccess if defined?(Rubocop)
