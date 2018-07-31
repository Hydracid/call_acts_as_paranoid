require 'bundler/setup'

require 'rubocop'
require 'rubocop/cop/internal_affairs'

require 'webmock/rspec'

require 'powerpack/string/strip_margin'
require 'pry'

# Require supporting files exposed for testing.
require 'rubocop/rspec/support'

require 'paranoia_support'

RSpec.configure do |config|
  unless defined?(::TestQueue)
    # See. https://github.com/tmm1/test-queue/issues/60#issuecomment-281948929
    config.filter_run :focus
    config.run_all_when_everything_filtered = true
  end

  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.include RuboCop::RSpec::ExpectOffense

  config.order = :random
  Kernel.srand config.seed

  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
    expectations.syntax = :expect # Disable `should`
  end

  config.mock_with :rspec do |mocks|
    mocks.syntax = :expect # Disable `should_receive` and `stub`
    mocks.verify_partial_doubles = true
  end

  config.after do
    RuboCop::PathUtil.reset_pwd
  end
end

require 'rubocop-rspec'
