# frozen_string_literal: true

RSpec.describe 'RuboCop Thread Safety project' do # rubocop:disable RSpec/DescribeClass
  describe 'department cop registration' do
    it 'registers every cop file in `lib/rubocop/cop/thread_safety` exactly once' do
      cop_root = File.expand_path('../lib/rubocop/cop', __dir__)
      files = Dir[File.join(cop_root, 'thread_safety', '*.rb')].sort

      registered = RuboCop::Cop::Registry.global.cops_for_department(:ThreadSafety).map do |cop|
        Object.const_source_location(cop.name).first
      end.sort

      expect(registered).to eq(files)
    end
  end

  describe 'default configuration' do
    it 'links cops to their documentation' do
      config = RuboCop::Config.new(YAML.load_file(File.expand_path('../config/default.yml', __dir__)))

      expect(RuboCop::Cop::ThreadSafety::NewThread.documentation_url(config))
        .to eq('https://docs.rubocop.org/rubocop-thread_safety/cops_threadsafety.html#threadsafetynewthread')
    end
  end
end
