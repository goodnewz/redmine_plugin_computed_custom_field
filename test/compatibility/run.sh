#!/usr/bin/env bash
# Only run in a disposable official Redmine container: this replaces its DB config.
set -euo pipefail
cd /usr/src/redmine

# Slim images omit the compiler needed by some test-only gems.
if ! command -v make >/dev/null || ! command -v gcc >/dev/null; then
  apt-get update
  apt-get install -y --no-install-recommends build-essential
fi

: > config/database.yml
for environment in test compatibility; do
  cat >> config/database.yml <<YAML
$environment:
  adapter: sqlite3
  database: db/computed_custom_field_test.sqlite3
YAML
done

bundle config set --local without development
bundle install --jobs 4

export RAILS_ENV=test
bundle exec rake db:migrate redmine:plugins:migrate NAME=computed_custom_field
# Exercise rollback and reinstall as well as the fresh installation above.
bundle exec rake redmine:plugins:migrate NAME=computed_custom_field VERSION=0
bundle exec rake redmine:plugins:migrate NAME=computed_custom_field
bundle exec rake redmine:plugins:test NAME=computed_custom_field

# Use production settings without development-only dependencies.
cat > config/environments/compatibility.rb <<'RUBY'
require_relative 'production'
Rails.application.configure do
  config.eager_load = ENV.fetch('EAGER_LOAD', 'false') == 'true'
  # Redmine 5 cannot re-run core preparation: https://www.redmine.org/issues/38155
  config.cache_classes = config.eager_load || Rails::VERSION::MAJOR < 7
  config.log_level = :warn
  config.secret_key_base = 'computed-custom-field-disposable-test-only'
end
RUBY

for eager_load in false true; do
  RAILS_ENV=compatibility EAGER_LOAD="$eager_load" bundle exec rails runner plugins/computed_custom_field/test/compatibility/loading.rb
done

if [[ "${RUN_UI_TESTS:-0}" == 1 ]]; then
  apt-get update
  apt-get install -y --no-install-recommends chromium chromium-driver
  GOOGLE_CHROME_OPTS_ARGS=--headless,--no-sandbox,--disable-dev-shm-usage \
    bundle exec rake redmine:plugins:test:ui NAME=computed_custom_field
fi
