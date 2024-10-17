# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'rubocop/thread_safety/version'

Gem::Specification.new do |spec|
  spec.name          = 'rubocop-thread_safety'
  spec.version       = RuboCop::ThreadSafety::VERSION
  spec.authors       = ['Michael Gee']
  spec.email         = ['michaelpgee@gmail.com']

  spec.summary       = 'Thread-safety checks via static analysis'
  spec.description   = <<-DESCRIPTION
    Thread-safety checks via static analysis.
    A plugin for the RuboCop code style enforcing & linting tool.
  DESCRIPTION
  spec.homepage = 'https://github.com/rubocop/rubocop-thread_safety'
  spec.licenses = ['MIT']

  spec.files = `git ls-files -z`.split("\x0").reject do |f|
    f.match(%r{^(test|spec|features)/})
  end

  spec.metadata = {
    'changelog_uri' => 'https://github.com/rubocop/rubocop-thread_safety/blob/master/CHANGELOG.md',
    'source_code_uri' => 'https://github.com/rubocop/rubocop-thread_safety',
    'bug_tracker_uri' => 'https://github.com/rubocop/rubocop-thread_safety/issues',
    'rubygems_mfa_required' => 'true'
  }

  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.required_ruby_version = '>= 2.7.0'

  spec.add_dependency 'rubocop', '>= 1.48.1'
end
