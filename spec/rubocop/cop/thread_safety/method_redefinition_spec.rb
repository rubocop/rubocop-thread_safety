# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ThreadSafety::MethodRedefinition, :config do
  it 'registers an offense when using `remove_method` followed by method definition' do
    expect_offense(<<~RUBY)
      remove_method :foo
      ^^^^^^^^^^^^^^^^^^ Do not use `remove_method` followed by method definition.
      def foo; end
    RUBY
  end

  it 'registers an offense when using `remove_method` with `str` argument followed by method definition' do
    expect_offense(<<~RUBY)
      remove_method "foo"
      ^^^^^^^^^^^^^^^^^^^ Do not use `remove_method` followed by method definition.
      def foo; end
    RUBY
  end

  it 'registers an offense within `class << self` scope' do
    expect_offense(<<~RUBY)
      class << self
        remove_method "foo"
        ^^^^^^^^^^^^^^^^^^^ Do not use `remove_method` followed by method definition.
        def foo; end
      end
    RUBY
  end

  it 'does not register an offense for different scopes' do
    expect_no_offenses(<<~RUBY)
      class << self
        remove_method "foo"
      end

      def foo; end
    RUBY
  end

  it 'does not register an offense when using `remove_method` without any arguments`' do
    expect_no_offenses(<<~RUBY)
      remove_method
      def foo; end
    RUBY
  end

  it 'does not register an offense when using `remove_method` with non-literal argument`' do
    expect_no_offenses(<<~RUBY)
      remove_method method_name()
      def foo; end
    RUBY
  end

  it 'does not register an offense when using `remove_method` with more than argument`' do
    expect_no_offenses(<<~RUBY)
      remove_method :foo, :bar
      def foo; end
    RUBY
  end

  it 'does not register an offense when using `remove_method` with unrelated method name argument' do
    expect_no_offenses(<<~RUBY)
      remove_method :bar
      def foo; end
    RUBY
  end

  it 'does not register an offense when using `remove_method` without method definitions' do
    expect_no_offenses(<<~RUBY)
      remove_method :foo
    RUBY
  end

  it 'does not register an offense when using `remove_method` followed by a unrelated node' do
    expect_no_offenses(<<~RUBY)
      remove_method :foo
      bar
    RUBY
  end
end
