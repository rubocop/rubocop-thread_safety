# frozen_string_literal: true

require_relative 'mixin/operation_with_threadsafe_result'

module RuboCop
  module Cop
    # Cops for the `ThreadSafety` department. The department's cops are
    # registered for lazy loading and their files are loaded on demand.
    module ThreadSafety
      extend LazyLoader

      register_cop :ActiveSupportCallbacks, "#{__dir__}/thread_safety/active_support_callbacks"
      register_cop :ClassInstanceVariable, "#{__dir__}/thread_safety/class_instance_variable"
      register_cop :ClassAndModuleAttributes, "#{__dir__}/thread_safety/class_and_module_attributes"
      register_cop :MutableClassInstanceVariable, "#{__dir__}/thread_safety/mutable_class_instance_variable"
      register_cop :NewThread, "#{__dir__}/thread_safety/new_thread"
      register_cop :DirChdir, "#{__dir__}/thread_safety/dir_chdir"
      register_cop :EnvMutation, "#{__dir__}/thread_safety/env_mutation"
      register_cop :RackMiddlewareInstanceVariable, "#{__dir__}/thread_safety/rack_middleware_instance_variable"
      register_cop :MethodRedefinition, "#{__dir__}/thread_safety/method_redefinition"
      register_cop :LazySynchronizationPrimitive, "#{__dir__}/thread_safety/lazy_synchronization_primitive"
    end
  end
end
