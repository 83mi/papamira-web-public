#!/bin/bash
reset
#rackup -E production -s puma -p 4567 -o 0.0.0.0
#rackup -E development -s puma -p 4567 -o 0.0.0.0
#rackup -E test -s puma -p 4567 -o 0.0.0.0

#env RACK_ENV=development bundle exec thin start
#env RACK_ENV=development bundle exec puma -C config/puma.rb
#env RACK_ENV=production bundle exec puma -C config/puma.rb
#env RACK_ENV=test bundle exec puma -C config/puma.rb

#export RACK_ENV=production
export RACK_ENV=development
#bundle exec thin --ssl start
bundle exec thin start
#bundle exec puma -C config/puma.rb
