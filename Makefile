# Makefile

.PHONY: server setup db

# Install dependencies and setup the project
setup:
	bundle install
	bin/rails db:create db:migrate

# Start the server
server:
	bin/rails server
