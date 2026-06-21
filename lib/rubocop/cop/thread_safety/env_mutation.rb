# frozen_string_literal: true

module RuboCop
  module Cop
    module ThreadSafety
      # Avoid mutating `ENV`.
      #
      # Environment variables are process-wide. Mutating them can affect other
      # threads, requests, jobs, or subprocesses running in the same Ruby
      # process.
      #
      # @example
      #   # bad
      #   ENV['TZ'] = 'UTC'
      #
      #   # bad
      #   ENV.update('FOO' => 'bar')
      #
      #   # good
      #   system({ 'TZ' => 'UTC' }, 'date')
      #
      #   # good
      #   ENV.fetch('TZ', 'UTC')
      class EnvMutation < Base
        MSG = 'Avoid mutating `ENV` due to its process-wide effect.'
        RESTRICT_ON_SEND = %i[
          []=
          store
          update
          merge!
          replace
          delete
          delete_if
          reject!
          keep_if
          select!
          filter!
          shift
          clear
        ].freeze

        # @!method env_mutation?(node)
        def_node_matcher :env_mutation?, <<~PATTERN
          (call
            (const {nil? cbase} :ENV)
            {
              :[]=
              :store
              :update
              :merge!
              :replace
              :delete
              :delete_if
              :reject!
              :keep_if
              :select!
              :filter!
              :shift
              :clear
            }
            ...)
        PATTERN

        def on_send(node)
          return unless env_mutation?(node)

          add_offense(node)
        end
        alias on_csend on_send
      end
    end
  end
end
