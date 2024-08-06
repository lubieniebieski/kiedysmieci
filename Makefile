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
	ruby lib/data_cleaner.rb GO 

get_data:
	curl -X POST ${TRASH_DATA_URL} > data.json

update_data: get_data clean_data 
