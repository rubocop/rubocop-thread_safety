# frozen_string_literal: true

module RuboCop
  module Cop
    module ThreadSafety
      # Avoid the thread-unsafe combination of remove_method followed by defining a method with the same name.
      # This can lead to a race condition, as these two actions are not atomic.
      # As a safer alternative, consider aliasing the method to itself instead.
      #
      # @example
      #   # bad
      #   remove_method :foo
      #   def foo; end
      #
      #   # good
      #   alias_method :foo, :foo
      #   def foo; end
      #
      #   # good
      #   alias foo foo
      #   def foo; end
      #
      class MethodRedefinition < Base
        MSG = 'Do not use `remove_method` followed by method definition.'

        RESTRICT_ON_SEND = %i[remove_method].freeze

        def on_send(node)
          return unless (def_node = node.right_sibling)
          return unless def_node.def_type?
          return unless node.arguments.one?
          return unless (method_name_node = node.first_argument).type?(:str, :sym)
          return unless def_node.method?(method_name_node.value)

          add_offense(node)
        end
        alias on_csend on_send
      end
    end
  end
end
