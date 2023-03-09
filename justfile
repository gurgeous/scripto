check: lint test

ci: check

lint:
  bundle exec rubocop

fmt:
  bundle exec rubocop -a

test:
  rake test
