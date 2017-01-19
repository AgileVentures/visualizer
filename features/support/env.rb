require 'cucumber/rails'
require 'capybara-screenshot/cucumber'
require 'email_spec/cucumber'
require_relative 'temporal'

ActionController::Base.allow_rescue = false

DatabaseCleaner.strategy = :transaction


Cucumber::Rails::Database.javascript_strategy = :truncation

Capybara.register_driver :poltergeist do |app|
  Capybara::Poltergeist::Driver.new(app, js_errors: false, timeout: 30)
end

Capybara.javascript_driver = :poltergeist
Capybara.default_max_wait_time = 10

World(Temporal)