# frozen_string_literal: true

RSpec.describe 'cop lazy loading' do # rubocop:disable RSpec/DescribeClass
  def run_script(source)
    Dir.mktmpdir do |dir|
      script = File.join(dir, 'script.rb')
      File.write(script, source)
      lib = File.expand_path('../lib', __dir__)
      output = `#{RbConfig.ruby} -I #{lib} #{script} 2>&1`
      raise "script failed:\n#{output}" unless $CHILD_STATUS.success?

      output
    end
  end

  it 'registers all cops without loading their files' do
    output = run_script(<<~RUBY)
      require 'rubocop-thread_safety'

      registry = RuboCop::Cop::Registry.global
      loaded = $LOADED_FEATURES.grep(%r{/rubocop/cop/thread_safety/})

      puts "registered=\#{registry.names.grep(%r{\\AThreadSafety/}).size}"
      puts "loaded_cop_files=\#{loaded.size}"
    RUBY

    expect(output).to include('registered=10', 'loaded_cop_files=0')
  end

  it 'does not register a cop twice when its file is required directly' do
    output = run_script(<<~RUBY)
      require 'rubocop-thread_safety'

      before = RuboCop::Cop::Registry.global.length
      require 'rubocop/cop/thread_safety/new_thread'
      after = RuboCop::Cop::Registry.global.length

      puts "stable=\#{before == after}"
      puts "class=\#{RuboCop::Cop::Registry.global.find_by_cop_name('ThreadSafety/NewThread')}"
    RUBY

    expect(output).to include('stable=true', 'class=RuboCop::Cop::ThreadSafety::NewThread')
  end
end
