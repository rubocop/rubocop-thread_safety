# frozen_string_literal: true

RSpec.describe RuboCop::Cop::ThreadSafety::EnvMutation, :config do
  let(:msg) { 'Avoid mutating `ENV` due to its process-wide effect.' }

  [
    'ENV["FOO"] = "bar"',
    'ENV.store("FOO", "bar")',
    'ENV.update("FOO" => "bar")',
    'ENV.merge!("FOO" => "bar")',
    'ENV.replace("FOO" => "bar")',
    'ENV.delete("FOO")',
    'ENV.shift',
    'ENV.clear',
    '::ENV.update("FOO" => "bar")',
    'ENV&.update("FOO" => "bar")'
  ].each do |expression|
    it "registers an offense for `#{expression}`" do
      expect_offense(<<~RUBY, expression: expression, msg: msg)
        %{expression}
        ^{expression} %{msg}
      RUBY
    end
  end

  %w[delete_if reject! keep_if select! filter!].each do |method_name|
    it "registers an offense for `ENV.#{method_name}` with a block" do
      expect_offense(<<~RUBY, expression: "ENV.#{method_name}", msg: msg)
        %{expression} { |_key, _value| true }
        ^{expression} %{msg}
      RUBY
    end
  end

  it 'does not register an offense for reading from ENV' do
    expect_no_offenses(<<~RUBY)
      ENV["FOO"]
      ENV.fetch("FOO", "bar")
      ENV.key?("FOO")
      ENV.to_h
      ENV.merge("FOO" => "bar")
    RUBY
  end

  it 'does not register an offense for per-command environment hashes' do
    expect_no_offenses(<<~RUBY)
      system({ "FOO" => "bar" }, "echo")
      Open3.capture3({ "FOO" => "bar" }, "echo")
    RUBY
  end

  it 'does not register an offense for unrelated receivers' do
    expect_no_offenses(<<~RUBY)
      env["FOO"] = "bar"
      Other::ENV.update("FOO" => "bar")
    RUBY
  end
end
