# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ThreadSafety::LazySynchronizationPrimitive, :config do
  it 'registers an offense when lazily initializing a `Mutex` in an instance method' do
    expect_offense(<<~RUBY)
      def mutex
        @mutex ||= Mutex.new
        ^^^^^^^^^^^^^^^^^^^^ Do not lazily initialize synchronization primitives with `||=`.
      end
    RUBY
  end

  it 'registers an offense when lazily initializing a `Mutex` in an endless method', :ruby30 do
    expect_offense(<<~RUBY)
      def mutex = @mutex ||= Mutex.new
                  ^^^^^^^^^^^^^^^^^^^^ Do not lazily initialize synchronization primitives with `||=`.
    RUBY
  end

  it 'registers an offense when lazily initializing a `Mutex` in a class method' do
    expect_offense(<<~RUBY)
      def self.mutex
        @mutex ||= Mutex.new
        ^^^^^^^^^^^^^^^^^^^^ Do not lazily initialize synchronization primitives with `||=`.
      end
    RUBY
  end

  it 'registers an offense when lazily initializing a `Monitor`' do
    expect_offense(<<~RUBY)
      def monitor
        @monitor ||= Monitor.new
        ^^^^^^^^^^^^^^^^^^^^^^^^ Do not lazily initialize synchronization primitives with `||=`.
      end
    RUBY
  end

  it 'registers an offense when lazily initializing `Thread::Mutex`' do
    expect_offense(<<~RUBY)
      def mutex
        @mutex ||= Thread::Mutex.new
        ^^^^^^^^^^^^^^^^^^^^^^^^^^^^ Do not lazily initialize synchronization primitives with `||=`.
      end
    RUBY
  end

  it 'registers an offense when lazily initializing a class variable' do
    expect_offense(<<~RUBY)
      def mutex
        @@mutex ||= Mutex.new
        ^^^^^^^^^^^^^^^^^^^^^ Do not lazily initialize synchronization primitives with `||=`.
      end
    RUBY
  end

  it 'does not register an offense when eagerly assigning a `Mutex`' do
    expect_no_offenses(<<~RUBY)
      def initialize
        @mutex = Mutex.new
      end
    RUBY
  end

  it 'does not register an offense when using a constant' do
    expect_no_offenses(<<~RUBY)
      MUTEX = Mutex.new

      def mutex
        MUTEX
      end
    RUBY
  end

  it 'does not register an offense when lazily initializing inside `synchronize`' do
    expect_no_offenses(<<~RUBY)
      def mutex
        LOADER.synchronize do
          @mutex ||= Mutex.new
        end
      end
    RUBY
  end

  it 'does not register an offense when lazily initializing a non-synchronization primitive' do
    expect_no_offenses(<<~RUBY)
      def cache
        @cache ||= {}
      end
    RUBY
  end

  it 'does not register an offense when using a local variable' do
    expect_no_offenses(<<~RUBY)
      def mutex
        mutex ||= Mutex.new
      end
    RUBY
  end

  it 'does not register an offense when lazily initializing outside a method' do
    expect_no_offenses(<<~RUBY)
      @mutex ||= Mutex.new
    RUBY
  end

  it 'does not register an offense when assigning without `||=`' do
    expect_no_offenses(<<~RUBY)
      def mutex
        @mutex = Mutex.new
      end
    RUBY
  end
end
