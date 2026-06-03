# frozen_string_literal: true

module RuboCop
  module Cop
    module ThreadSafety
      # Avoid lazily initializing synchronization primitives with `||=`.
      #
      # The check-then-set performed by `||=` is not atomic, so concurrent threads
      # can observe an uninitialized primitive or create more than one instance.
      # Eagerly assign the primitive (for example in `initialize`) or use a constant.
      #
      # @example
      #   # bad
      #   def mutex
      #     @mutex ||= Mutex.new
      #   end
      #
      #   # bad
      #   def mutex = @mutex ||= Mutex.new
      #
      #   # good
      #   def initialize
      #     @mutex = Mutex.new
      #   end
      #
      class LazySynchronizationPrimitive < Base
        MSG = 'Do not lazily initialize synchronization primitives with `||=`.'

        # @!method lazy_shared_variable_assignment?(node)
        def_node_matcher :lazy_shared_variable_assignment?, <<~PATTERN
          (or_asgn ${ivasgn cvasgn} _)
        PATTERN

        # @!method synchronization_primitive?(node)
        def_node_matcher :synchronization_primitive?, <<~PATTERN
          {
            (send (const {nil? cbase} {:Mutex :Monitor}) :new ...)
            (send (const (const nil? :Thread) :Mutex) :new ...)
          }
        PATTERN

        def on_or_asgn(node)
          return unless lazy_shared_variable_assignment?(node)
          return unless synchronization_primitive?(node.rhs)
          return unless method_definition?(node)
          return if synchronized?(node)

          add_offense(node)
        end

        private

        def method_definition?(node)
          node.each_ancestor(:any_def).any?
        end

        def synchronized?(node)
          node.each_ancestor(:block).any? do |ancestor|
            ancestor.method?(:synchronize)
          end
        end
      end
    end
  end
end
