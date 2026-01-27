
# read gem version
gemver := `cat lib/scripto/version.rb | grep -Eo "[0-9]+\.[0-9]+\.[0-9]+"`

set quiet := true

#
# dev
#

default: test

check: lint test

fmt:
  bundle exec rubocop -a

lint:
  just banner lint...
  bundle exec rubocop

pry:
  bundle exec pry -I lib -r scripto.rb

test:
  just banner test...
  bundle exec rake test

watch:
  watchexec --watch lib --watch test --clear bundle exec rake test

#
# gem tasks
#

gem-push: check-git-status
  just banner gem build...
  gem build scripto.gemspec
  just banner tag...
  #git tag -a "v{{gemver}}" -m "Tagging {{gemver}}"
  #git push --tags
  just banner gem push...
  #gem push "scripto-{{gemver}}.gem"

#
# util
#

GREEN := '\e[1;38;2;255;255;255;48;2;64;160;43m'
banner *ARGS:
  printf '{{GREEN}}[%s] %-72s \e[m\n' "$(date +%H:%M:%S)" "{{ARGS}}"

check-git-status:
  if [ ! -z "$(git status --porcelain)" ]; then echo "git status is dirty, bailing."; exit 1; fi
