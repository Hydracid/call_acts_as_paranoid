source 'https://rubygems.org'

git_source(:github) { |repo_name| "https://github.com/#{repo_name}" }

# Specify your gem's dependencies in paranoia_support.gemspec
gemspec

gem 'pry', require: false
gem 'rake', require: false
gem 'rspec', require: false
gem 'rubocop', require: false
gem 'rubocop-rspec', require: false

group :test do
  gem 'codeclimate-test-reporter', '~> 1.0', require: false
  gem 'public_suffix', '~> 2.0', require: false
  gem 'safe_yaml', require: false
  gem 'webmock', require: false
end
