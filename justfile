#
# dev
#

test:
  rake test

lint:
  bundle exec rubocop

fmt:
  bundle exec rubocop -a

pry:
  pry -I lib -r scripto.rb

check: lint test

# gem tasks
gem-build:
  gem build --quiet scripto.gemspec

# task install: :build do
#   sh "gem install --quiet scripto-#{spec.version}.gem"
# end

# task release: %i[rubocop test build] do
#   raise "looks like git isn't clean" unless `git status --porcelain`.empty?

#   sh "git tag -a #{spec.version} -m 'Tagging #{spec.version}'"
#   sh 'git push --tags'
#   sh "gem push scripto-#{spec.version}.gem"
# end
