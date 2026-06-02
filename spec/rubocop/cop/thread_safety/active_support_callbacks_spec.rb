# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ThreadSafety::ActiveSupportCallbacks, :config do
  let(:gem_versions) { { 'activesupport' => '7.0.0' } }

  it 'registers an offense for `skip_callback` with a constant receiver' do
    expect_offense(<<~RUBY)
      Site.skip_callback(:commit, :after, :after_owner_change)
           ^^^^^^^^^^^^^ Avoid process-wide ActiveSupport callback mutation with `Site.skip_callback`.
    RUBY
  end

  it 'registers an offense for `set_callback` with a constant receiver' do
    expect_offense(<<~RUBY)
      Site.set_callback(:commit, :after, :after_owner_change, if: :saved_change_to_owner?)
           ^^^^^^^^^^^^ Avoid process-wide ActiveSupport callback mutation with `Site.set_callback`.
    RUBY
  end

  it 'registers an offense for fully qualified constant receivers' do
    expect_offense(<<~RUBY)
      ::Site.skip_callback(:commit, :after, :after_owner_change)
             ^^^^^^^^^^^^^ Avoid process-wide ActiveSupport callback mutation with `::Site.skip_callback`.
    RUBY
  end

  it 'registers an offense for nested constant receivers' do
    expect_offense(<<~RUBY)
      Admin::Site.set_callback(:commit, :after, :after_owner_change)
                  ^^^^^^^^^^^^ Avoid process-wide ActiveSupport callback mutation with `Admin::Site.set_callback`.
    RUBY
  end

  it 'registers an offense for parenthesized constant receivers' do
    expect_offense(<<~RUBY)
      (Site).set_callback(:commit, :after, :after_owner_change)
             ^^^^^^^^^^^^ Avoid process-wide ActiveSupport callback mutation with `(Site).set_callback`.
    RUBY
  end

  it 'registers an offense for safe navigation with a constant receiver' do
    expect_offense(<<~RUBY)
      Site&.skip_callback(:commit, :after, :after_owner_change)
            ^^^^^^^^^^^^^ Avoid process-wide ActiveSupport callback mutation with `Site&.skip_callback`.
    RUBY
  end

  it 'does not register an offense for ActiveSupport callback DSL calls' do
    expect_no_offenses(<<~RUBY)
      class User < ApplicationRecord
        skip_callback :commit, :after, :after_owner_change
        set_callback :commit, :after, :after_owner_change, if: :saved_change_to_owner?
      end
    RUBY
  end

  it 'does not register an offense for explicit non-constant receivers' do
    expect_no_offenses(<<~RUBY)
      site.skip_callback(:commit, :after, :after_owner_change)
      callback_owner.set_callback(:commit, :after, :after_owner_change)
      self.skip_callback(:commit, :after, :after_owner_change)
    RUBY
  end

  it 'does not register an offense for unrelated methods on constant receivers' do
    expect_no_offenses(<<~RUBY)
      Site.after_commit :after_owner_change
    RUBY
  end

  context 'without ActiveSupport' do
    let(:gem_versions) { {} }

    it 'does not register an offense' do
      expect_no_offenses(<<~RUBY)
        Site.skip_callback(:commit, :after, :after_owner_change)
      RUBY
    end
  end
end
