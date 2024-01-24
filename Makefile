.PHONY: server deploy

server:
	bundle exec rackup --host 0.0.0.0 -p 4567

deploy:
	flyctl deploy