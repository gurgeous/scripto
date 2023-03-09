
version := `cat lib/scripto/version.rb | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+"`

#
# dev
#

default: test

check: lint test

fmt:
  bundle exec rubocop -a

lint:
  @just banner lint...
  bundle exec rubocop

pry:
  pry -I lib -r scripto.rb

test:
  @just banner test...
  rake test


#
# gem tasks
#

gem-push: check-git-status
  @just banner gem build...
  gem build scripto.gemspec
  @just banner tag...
  #git tag -a "v{{version}}" -m "Tagging {{version}}"
  #git push --tags
  @just banner gem push...
  #gem push "scripto-{{version}}.gem"

#
# util
#

banner *ARGS:
  @printf '\e[42;37;1m[%s] %-72s \e[m\n' "$(date +%H:%M:%S)" "{{ARGS}}"

check-git-status:
  @if [ ! -z "$(git status --porcelain)" ]; then echo "git status is dirty, bailing."; exit 1; fi
