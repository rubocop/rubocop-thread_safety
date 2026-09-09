# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ThreadSafety::ClassInstanceVariable, :config do
  let(:msg) { 'Avoid class instance variables.' }

  it 'registers an offense for assigning to an ivar in a class method' do
    expect_offense(<<~RUBY)
      class Test
        def self.some_method(params)
          @params = params
          ^^^^^^^ #{msg}
        end
      end
    RUBY
  end

  it 'registers no offense when the assignment is synchronized by a mutex' do
    expect_no_offenses(<<~RUBY)
      class Test
        SEMAPHORE = Mutex.new
        def self.some_method(params)
          SEMAPHORE.synchronize do
            @params = params
          end
        end
      end
    RUBY
  end

  it 'registers no offense when memoization is synchronized by a mutex' do
    expect_no_offenses(<<~RUBY)
      class Test
        SEMAPHORE = Mutex.new
        def self.types
          SEMAPHORE
            .synchronize { @all_types ||= type_class.all }
        end
      end
    RUBY
  end

  it 'registers no offense for assigning an ivar in define_method' do
    expect_no_offenses(<<~RUBY)
      class Test
        def self.factory_method
          define_method(:some_method) do |params|
            @params = params
          end
        end
      end
    RUBY
  end

  it 'registers no offense for assigning an ivar in `Struct` scope' do
    expect_no_offenses(<<~RUBY)
      class Test
        def self.factory_method
          Struct.new(:width, :height) do
            def area
              @area ||= width * height
            end
          end
        end
      end
    RUBY
  end

  it 'registers no offense for assigning an ivar in `Data` scope' do
    expect_no_offenses(<<~RUBY)
      class Test
        def self.factory_method
          Data.define(:width, :height) do
            def area
              @area ||= width * height
            end
          end
        end
      end
    RUBY
  end

  it 'registers no offense for assigning an ivar in `Class` scope' do
    expect_no_offenses(<<~RUBY)
      class Test
        def self.factory_method
          Class.new do
            def area
              @area ||= some_computation
            end
          end
        end
      end
    RUBY
  end

  it 'registers no offense for `instance_variable_get` in new lexical scope' do
    expect_no_offenses(<<~RUBY)
      class Test
        def self.factory_method
          Class.new do
            def area
              instance_variable_get(:@area)
            end
          end
        end
      end
    RUBY
  end

  it 'registers an offense for reading an ivar in a nested class method' do # rubocop:disable RSpec/ExampleLength
    expect_offense(<<~RUBY)
      class Test
        define_method :generate_new_class do
          Class.new do
            def self.area
              @area ||= some_computation
              ^^^^^ #{msg}
            end
          end
        end
      end
    RUBY
  end

  it 'registers an offense for reading an ivar in a class method' do
    expect_offense(<<~RUBY)
      class Test
        def self.some_method
          do_work(@params)
                  ^^^^^^^ #{msg}
        end
      end
    RUBY
  end

  it 'registers an offense for assigning an ivar in module ClassMethods' do
    expect_offense(<<~RUBY)
      module ClassMethods
        def some_method(params)
          @params = params
          ^^^^^^^ #{msg}
        end
      end
    RUBY
  end

  it 'registers an offense for assigning an ivar in class_methods' do
    expect_offense(<<~RUBY)
      module Test
        class_methods do
          def some_method(params)
            @params = params
            ^^^^^^^ #{msg}
          end
        end
      end
    RUBY
  end

  # rubocop:disable-next RSpec/ExampleLength
  it 'registers an offense for assigning an ivar in class_methods within lambda', :with_legacy_lambda_node do
    expect_offense(<<~RUBY)
      module Test
        class_methods do
          ->() {
            def some_method(params)
              @params = params
              ^^^^^^^ #{msg}
            end
          }
        end
      end
    RUBY
  end

  it 'registers an offense for assigning an ivar in a class singleton method' do
    expect_offense(<<~RUBY)
      class Test
        class << self
          def some_method(params)
            @params = params
            ^^^^^^^ #{msg}
          end
        end
      end
    RUBY
  end

  it 'registers an offense for assigning an ivar in define_singleton_method' do
    expect_offense(<<~RUBY)
      class Test
        define_singleton_method(:some_method) do |params|
          @params = params
          ^^^^^^^ #{msg}
        end
      end
    RUBY
  end

  it 'registers an offense for ivar_get in a class method' do
    expect_offense(<<~RUBY)
      class Test
        def self.some_method
          do_work(instance_variable_get(:@params))
                  ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
        end
      end
    RUBY
  end

  it 'registers an offense for ivar_set in a class singleton method' do
    expect_offense(<<~RUBY)
      class Test
        class << self
          def some_method(name, params)
            instance_variable_set(:"@\#{name}", params)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
          end
        end
      end
    RUBY
  end

  it 'registers an offense for ivar_set in module ClassMethods' do
    expect_offense(<<~RUBY)
      module ClassMethods
        def some_method(params)
          instance_variable_set(:@params, params)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
        end
      end
    RUBY
  end

  it 'registers an offense for ivar_set in class_methods' do
    expect_offense(<<~RUBY)
      module Test
        class_methods do
          def some_method(params)
            instance_variable_set(:@params, params)
            ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
          end
        end
      end
    RUBY
  end

  it 'registers an offense for ivar_set in define_singleton_method' do
    expect_offense(<<~RUBY)
      class Test
        define_singleton_method(:some_method) do |params|
          instance_variable_set(:@params, params)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
        end
      end
    RUBY
  end

  it 'registers an offense for ivar_set in a method below module_function directive' do
    expect_offense(<<~RUBY)
      module Test
        module_function

        def some_method(params)
          instance_variable_set(:@params, params)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
        end
      end
    RUBY
  end

  it 'registers an offense for ivar_set in a method marked by module_function' do
    expect_offense(<<~RUBY)
      module Test
        def some_method(params)
          instance_variable_set(:@params, params)
          ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ #{msg}
        end

        module_function :some_method
      end
    RUBY
  end

  it 'does not register an offenses for synchronized ivar_set in a method marked by module_function' do
    expect_no_offenses(<<~RUBY)
      module Test
        def some_method(params)
          $mutex.synchronize do
            instance_variable_set(:@params, params)
          end
        end

        module_function :some_method
      end
    RUBY
  end

  it 'registers an offense for assigning an ivar in a method below module_function directive' do
    expect_offense(<<~RUBY)
      module Test
        module_function

        def some_method(params)
          @params = params
          ^^^^^^^ #{msg}
        end
      end
    RUBY
  end

  it 'registers an offense for assigning an ivar in a method marked by module_function' do
    expect_offense(<<~RUBY)
      module Test
        def some_method(params)
          @params = params
          ^^^^^^^ #{msg}
        end

        module_function :some_method
      end
    RUBY
  end

  it 'registers an offense for instance variable within `class_eval` block' do # rubocop:disable RSpec/ExampleLength
    expect_offense(<<~RUBY)
      def separate_with(separator)
        Example.class_eval do
          @separator = separator
          ^^^^^^^^^^ #{msg}
        end
      end
    RUBY

    expect_offense(<<~RUBY)
      def separate_with(separator)
        ::Example.class_eval do
          @separator = separator
          ^^^^^^^^^^ #{msg}
        end
      end
    RUBY
  end

  it 'registers an offense for instance variable within `class_exec` block' do
    expect_offense(<<~RUBY)
      def separate_with(separator)
        Example.class_exec do
          @separator = separator
          ^^^^^^^^^^ #{msg}
        end
      end
    RUBY
  end

  it 'registers no offense for ivar_set in define_method' do
    expect_no_offenses(<<~RUBY)
      class Test
        def self.factory_method
          define_method(:some_method) do |params|
            instance_variable_set(:@params, params)
          end
        end
      end
    RUBY
  end

  it 'registers no offense for using ivar_get on object in a class method' do
    expect_no_offenses(<<~RUBY)
      class Test
        def self.some_method(obj, params)
          obj.instance_variable_get(:@params)
        end
      end
    RUBY
  end

  it 'registers no offense for using ivar_set on object in a class method' do
    expect_no_offenses(<<~RUBY)
      class Test
        class << self
          def some_method(obj, params)
            obj.instance_variable_set(:@params, params)
          end
        end
      end
    RUBY
  end

  it 'registers no offense for using an ivar in an instance method' do
    expect_no_offenses(<<~RUBY)
      class Test
        def some_method(params)
          @params = params
          do_work(@params)
        end
      end
    RUBY
  end

  it 'registers no offense for using ivar methods in an instance method' do
    expect_no_offenses(<<~RUBY)
      class Test
        def some_method(params)
          instance_variable_set(:@params, params)
          do_work(instance_variable_get(:@params))
        end
      end
    RUBY
  end

  it 'registers no offense for using an ivar in a module below ClassMethods' do
    expect_no_offenses(<<~RUBY)
      module ClassMethods
        module Other
          def some_method(params)
            @params = params
          end
        end
      end
    RUBY
  end

  it 'registers no offense for assigning an ivar in a method above module_function directive' do
    expect_no_offenses(<<~RUBY)
      module Test
        def some_method(params)
          @params = params
        end

        module_function
      end
    RUBY
  end

  it 'registers no offense for assigning an ivar in a method not marked by module_function' do
    expect_no_offenses(<<~RUBY)
      module Test
        def some_method(params)
          @params = params
        end

        def another_method(params)
          puts params
        end

        module_function :another_method
      end
    RUBY
  end

  it 'does not register an offense for instance variable within `module_eval` block' do
    expect_no_offenses(<<~RUBY)
      def separate_with(separator)
        Utilities.module_eval do
          @separator = separator
        end
      end
    RUBY
  end

  it 'does not register an offense for instance variable within `module_exec` block' do
    expect_no_offenses(<<~RUBY)
      def separate_with(separator)
        Utilities.module_exec do
          @separator = separator
        end
      end
    RUBY
  end

  it 'does not register an offense for instance variable within `class_*` with new instance method' do
    expect_no_offenses(<<~RUBY)
      def separate_with(separator)
        Example.class_eval do
          def separator
            @separator
          end
        end
      end
    RUBY
  end

  it 'does not register an offense for instance variable within `class_*` with string argument' do
    expect_no_offenses(<<~RUBY)
      def separate_with(separator)
        Example.class_eval "@f = Kernel.exit"
      end
    RUBY
  end

  context 'with `ActionDispatch` callbacks' do
    %i[
      prepend_around_action
      prepend_before_action
      before_action
      append_before_action
      around_action
      append_around_action
      append_after_action
      after_action
      prepend_after_action
    ].each do |action_dispatch_callback_name|
      it "registers no offense for `#{action_dispatch_callback_name}` callback" do
        expect_no_offenses(<<~RUBY)
          def self.foo
            #{action_dispatch_callback_name} do
              @language = :haskell
            end
          end
        RUBY
      end
    end
  end
end
