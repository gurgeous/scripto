test:
  rake test

lint:
  bundle exec rubocop

fmt:
  bundle exec rubocop -a

check: lint test
