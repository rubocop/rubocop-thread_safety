# Change log

* [#104](https://github.com/rubocop/rubocop-thread_safety/pull/104): Set minimum required RuboCop version to `1.81`. ([@viralpraxis][])
* [#95](https://github.com/rubocop/rubocop-thread_safety/pull/94): Add new `ThreadSafety/MethodRedefinition` cop. ([@viralpraxis][])
* [#91](https://github.com/rubocop/rubocop-thread_safety/pull/91): Make `ThreadSafety/MutableClassInstanceVariable` cop aware of `TestCase`'s `setup`/`teardown` DSL. ([@viralpraxis][])

## 0.7.3

* [#93](https://github.com/rubocop/rubocop-thread_safety/pull/93): Fix an error for `ThreadSafety/MutableClassInstanceVariable` cop. ([@viralpraxis][])

## 0.7.2

* [#88](https://github.com/rubocop/rubocop-thread_safety/pull/88): Fix incorrect plugin metadata version. ([@viralpraxis][])

## 0.7.1

* [#84](https://github.com/rubocop/rubocop-thread_safety/pull/84): Rename `InstanceVariableInClassMethod` in default config ([@sambostock][])

## 0.7.0

* [#80](https://github.com/rubocop/rubocop-thread_safety/pull/80) Make RuboCop ThreadSafety work as a RuboCop plugin. ([@bquorning][])
* [#76](https://github.com/rubocop/rubocop-thread_safety/pull/76): Detect offenses when using safe navigation for `ThreadSafety/DirChdir`, `ThreadSafety/NewThread` and `ThreadSafety/RackMiddlewareInstanceVariable` cops. ([@viralpraxis][])
* [#73](https://github.com/rubocop/rubocop-thread_safety/pull/73): Add `AllowCallWithBlock` option to `ThreadSafety/DirChdir` cop. ([@viralpraxis][])

## 0.6.0

* [#59](https://github.com/rubocop/rubocop-thread_safety/pull/59): Rename `ThreadSafety::InstanceVariableInClassMethod` cop to `ThreadSafety::ClassInstanceVariable` to better reflect its purpose. ([@viralpraxis][])
* [#55](https://github.com/rubocop/rubocop-thread_safety/pull/55): Enhance `ThreadSafety::InstanceVariableInClassMethod` cop to detect offenses within `class_eval/exec` blocks. ([@viralpraxis][])
* [#54](https://github.com/rubocop/rubocop-thread_safety/pull/54): Drop support for RuboCop older than 1.48. ([@viralpraxis][])
* [#52](https://github.com/rubocop/rubocop-thread_safety/pull/52): Add new `RackMiddlewareInstanceVariable` cop to detect instance variables in Rack middleware. ([@viralpraxis][])
* [#48](https://github.com/rubocop/rubocop-thread_safety/pull/48): Do not report instance variables in `ActionDispatch` callbacks in singleton methods. ([@viralpraxis][])
* [#43](https://github.com/rubocop/rubocop-thread_safety/pull/43): Make detection of ActiveSupport's `class_attribute` configurable. ([@viralpraxis][])
* [#42](https://github.com/rubocop/rubocop-thread_safety/pull/42): Fix some `InstanceVariableInClassMethod` cop false positive offenses. ([@viralpraxis][])
* [#41](https://github.com/rubocop/rubocop-thread_safety/pull/41): Drop support for MRI older than 2.7. ([@viralpraxis][])
* [#38](https://github.com/rubocop/rubocop-thread_safety/pull/38): Fix `NewThread` cop detection is case of `Thread.start`, `Thread.fork`, or `Thread.new` with arguments. ([@viralpraxis][])
* [#36](https://github.com/rubocop/rubocop-thread_safety/pull/36): Add new `DirChdir` cop to detect `Dir.chdir` calls. ([@viralpraxis][])

[@bquorning]: https://github.com/bquorning
[@sambostock]: https://github.com/sambostock
[@viralpraxis]: https://github.com/viralpraxis
