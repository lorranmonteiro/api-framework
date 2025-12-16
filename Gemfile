source "https://rubygems.org"

gem "rails", "~> 8.1.1"
gem "puma", ">= 5.0"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false
gem 'rswag'
gem 'rack-cors'

group :development, :test do
  gem "sqlite3", ">= 2.1"
end

group :development do
  gem "debug", platforms: %i[ mri windows ], require: "debug/prelude"
  gem "bundler-audit", require: false
  gem "brakeman", require: false
  gem "rubocop-rails-omakase", require: false
end

group :test do
  gem 'rspec-rails'
  gem 'factory_bot_rails'
  gem 'shoulda-matchers', '~> 5.0'
  gem 'faker'
end

group :production do
  gem "pg"
end
