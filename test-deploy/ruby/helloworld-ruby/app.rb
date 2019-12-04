require 'sinatra'
# add
start = Time.now
require 'rails', '~> 5.0.1'
require 'sqlite3'
require 'puma', '~> 3.0'
require 'sass-rails', '~> 5.0'
require 'uglifier', '>= 1.3.0'
require 'coffee-rails', '~> 4.2'

require 'jquery-rails'
require 'turbolinks', '~> 5'
require 'jbuilder', '~> 2.5'
require 'byebug', platform: :mri
require 'rspec-rails'
require 'factory_bot_rails'
require 'license_finder'
require 'web-console', '>= 3.3.0'
require 'listen', '~> 3.0.5'
require 'spring'
require 'spring-watcher-listen', '~> 2.0.0'
require 'rubocop'
require 'brakeman'
require 'bundler-audit'
require 'rack-mini-profiler'
require 'better_errors'
require 'binding_of_caller'
require 'bullet'
require 'rufo'
require 'annotate'
require 'rails_best_practices', require: false
end_time = Time.now
colapsed_time = end_time - start_time
set :bind, '0.0.0.0'

get '/' do
  target = ENV['TARGET'] || 'World'
  "Hello #{target}! #{colapsed_time}\n"
end
