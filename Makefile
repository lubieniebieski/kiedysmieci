.PHONY: server deploy

ifneq (,$(wildcard ./.env))
    include .env
    export
endif

server:
	mise run server

deploy:
	flyctl deploy

clean_data:
	rm tmp/schedules_cache.json

