source "https://rubygems.org"

gemspec

gem "appraisal"
gem "standardrb"
gem "sqlite3", "~> 1.4.4"
gem "pg"

if defined?(@ar_gem_requirement)
  gem "activerecord", @ar_gem_requirement
  gem "railties", @ar_gem_requirement
else
  gem "activerecord" # latest
end
