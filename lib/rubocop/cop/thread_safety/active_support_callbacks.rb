# frozen_string_literal: true

module RuboCop
  module Cop
    module ThreadSafety
      # Avoid mutating ActiveSupport callback chains at runtime.
      #
      # Calls such as `User.skip_callback` and `User.set_callback` mutate callback
      # chains at process scope.
      #
      # @example
      #   # bad
      #   Site.skip_callback(:commit, :after, :after_owner_change)
      #
      #   # bad
      #   Site.set_callback(
      #     :commit, :after, :after_owner_change,
      #     if: :saved_change_to_owner?
      #   )
      #
      #   # good
      #   class User < ApplicationRecord
      #     skip_callback :commit, :after, :after_owner_change
      #   end
      class ActiveSupportCallbacks < Base
        requires_gem 'activesupport'

        MSG = 'Avoid process-wide ActiveSupport callback mutation with `%<expression>s`.'
        RESTRICT_ON_SEND = %i[set_callback skip_callback].freeze

        def on_send(node)
          return unless constant_receiver?(node.receiver)

          add_offense(node.loc.selector, message: format(MSG, expression: callback_call(node)))
        end
        alias on_csend on_send

        private

        def constant_receiver?(receiver)
          receiver = receiver.children.first while receiver&.begin_type? && receiver.children.one?

          receiver&.const_type?
        end

        def callback_call(node)
          "#{node.receiver.source}#{node.loc.dot.source}#{node.method_name}"
        end
      end
    end
  end
end
