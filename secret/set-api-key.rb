# -*- encoding: utf-8 -*-
require 'json'

api_key = JSON.parse(File.open("api-key.json").read)
api_key.each do |server, key|
  system("unset PPAP_#{server.upcase}_API_KEY")
  system("export PPAP_#{server.upcase}_API_KEY=#{key}")
  system("heroku config:unset PPAP_#{server.upcase}_API_KEY")
  system("heroku config:set PPAP_#{server.upcase}_API_KEY=#{key}")
  p "export PPAP_#{server.upcase}_API_KEY=#{key}"
end
