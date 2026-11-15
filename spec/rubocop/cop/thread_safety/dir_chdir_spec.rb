# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ThreadSafety::DirChdir, :config do
  %w[Dir.chdir Dir&.chdir FileUtils.chdir FileUtils.cd].each do |expression|
    context "with `#{expression}` call" do
      it 'registers an offense' do
        expect_offense(<<~RUBY, expression: expression)
          %{expression}("/var/run")
          ^{expression}^^^^^^^^^^^^ Avoid using `%{expression}` due to its process-wide effect.
        RUBY
      end

      it 'registers an offense without arguments' do
        expect_offense(<<~RUBY, expression: expression)
          %{expression}
          ^{expression} Avoid using `%{expression}` due to its process-wide effect.
        RUBY
      end

      it 'registers an offense with fully quialified constant name' do
        expect_offense(<<~RUBY, expression: expression)
          ::%{expression}("/var/run")
          ^{expression}^^^^^^^^^^^^^^ Avoid using `%{expression}` due to its process-wide effect.
        RUBY
      end

      it 'registers an offense with provided block' do
        expect_offense(<<~RUBY, expression: expression)
          %{expression}("/var/run") do
          ^{expression}^^^^^^^^^^^^ Avoid using `%{expression}` due to its process-wide effect.
            puts Dir.pwd
          end
        RUBY
      end

      it 'registers an offense with provided block with argument' do
        expect_offense(<<~RUBY, expression: expression)
          %{expression}("/var/run") do |dir|
          ^{expression}^^^^^^^^^^^^ Avoid using `%{expression}` due to its process-wide effect.
            puts dir
          end
        RUBY
      end

      it 'registers an offense with a numbered block parameter', :ruby27 do
        expect_offense(<<~RUBY, expression: expression)
          %{expression}("/var/run") { puts _1 }
          ^{expression}^^^^^^^^^^^^ Avoid using `%{expression}` due to its process-wide effect.
        RUBY
      end

      it 'registers an offense with provided block argument' do
        expect_offense(<<~RUBY, expression: expression)
          def change_dir(&block)
            %{expression}("/var/run", &block)
            ^{expression}^^^^^^^^^^^^^^^^^^^^ Avoid using `%{expression}` due to its process-wide effect.
          end
        RUBY
      end
    end
  end

  %w[Dir FileUtils].each do |constant_name|
    it "does not register an offense for unrelated `#{constant_name}` method" do
      expect_no_offenses(<<~RUBY)
        #{constant_name}.pwd
      RUBY
    end
  end

  %w[chdir cd].each do |method_name|
    it "does not register an offense for unrelated `#{method_name}` with unrelated receiver" do
      expect_no_offenses(<<~RUBY)
        Foo.#{method_name}
      RUBY

      expect_no_offenses(<<~RUBY)
        foo.#{method_name}
      RUBY

      expect_no_offenses(<<~RUBY)
        #{method_name}
      RUBY
    end
  end

  context 'with `AllowCallWithBlock` configuration option set to `true`' do
    let(:cop_config) do
      { 'Enabled' => true, 'AllowCallWithBlock' => true }
    end

    %w[Dir.chdir FileUtils.chdir FileUtils.cd].each do |expression|
      it 'registers an offense for block-less call' do
        expect_offense(<<~RUBY, expression: expression)
          %{expression}("/var/run")
          ^{expression}^^^^^^^^^^^^ Avoid using `%{expression}` due to its process-wide effect.
        RUBY
      end

      it 'registers an offense for a block-less call inside another block' do
        expect_offense(<<~RUBY, expression: expression)
          1.times do
            %{expression}("/var/run")
            ^{expression}^^^^^^^^^^^^ Avoid using `%{expression}` due to its process-wide effect.
          end
        RUBY
      end

      it 'does not register an offense with a numbered block parameter', :ruby27 do
        expect_no_offenses(<<~RUBY)
          #{expression}("/var/run") { puts _1 }
        RUBY
      end

      it 'does not register an offense for block-ful call' do
        expect_no_offenses(<<~RUBY)
          #{expression}("/var/run") do
            p Dir.pwd
          end
        RUBY
      end

      it 'does no register an offense with provided block with argument' do
        expect_no_offenses(<<~RUBY)
          #{expression}("/var/run") do |dir|
            p dir
          end
        RUBY
      end

      it 'does not register an offense with provided block argument' do
        expect_no_offenses(<<~RUBY)
          def change_dir(&block)
            #{expression}("/var/run", &block)
          end
        RUBY
      end
    end
  end
end
