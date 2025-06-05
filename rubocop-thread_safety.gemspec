# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubocop/thread_safety/version'

Gem::Specification.new do |spec|
  spec.name          = 'rubocop-thread_safety'
  spec.version       = RuboCop::ThreadSafety::Version::STRING
  spec.authors       = ['Michael Gee']
  spec.email         = ['michaelpgee@gmail.com']

  spec.summary       = 'Thread-safety checks via static analysis'
  spec.description   = <<-DESCRIPTION
    Thread-safety checks via static analysis.
    A plugin for the RuboCop code style enforcing & linting tool.
  DESCRIPTION
  spec.homepage = 'https://github.com/rubocop/rubocop-thread_safety'
  spec.licenses = ['MIT']

  spec.files = IO.popen(%w[git ls-files -z], chdir: __dir__, err: IO::NULL) do |ls|
    ls.readlines("\x0", chomp: true).reject do |f|
      (f == File.basename(__FILE__)) || f.start_with?(
        *%w[
          bin/ spec/ .git .github/ bin/ docs/ gemfiles/ tasks/
          Gemfile Appraisals .rspec .rubocop.yml .yamllint.yml Rakefile
        ]
      )
    end
  end

  spec.metadata = {
    'changelog_uri' => 'https://github.com/rubocop/rubocop-thread_safety/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/rubocop/rubocop-thread_safety',
    'bug_tracker_uri' => 'https://github.com/rubocop/rubocop-thread_safety/issues',
    'rubygems_mfa_required' => 'true',
    'default_lint_roller_plugin' => 'RuboCop::ThreadSafety::Plugin'
  }

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7.0'

  spec.add_dependency 'lint_roller', '~> 1.1'
  spec.add_dependency 'rubocop', '~> 1.72', '>= 1.72.1'
  spec.add_dependency 'rubocop-ast', '>= 1.44.0', '< 2.0'
end
