.PHONY: server deploy

ifneq (,$(wildcard ./.env))
    include .env
    export
endif

server:
	bundle exec rackup --host 0.0.0.0 -p 4567

deploy:
	flyctl deploy

clean_data:
	rm tmp/schedules_cache.json

