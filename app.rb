# -*- encoding: utf-8 -*-

require_relative 'lib/api'
require_relative 'lib/text2voice'
require_relative 'lib/version'

require 'sinatra/base'
require 'sinatra/cookies'
require 'sinatra/activerecord'
require 'json'
require 'kconv'
require "nkf"
require 'cgi'
require 'date'
require 'digest/md5'
require 'parsedate'
require 'dotenv'
require 'zlib'
require 'base64'

require 'net/http'
require 'addressable/uri'
require 'securerandom'
require 'redis'
require 'rest-client'

require_relative 'models/papamira.rb'
Dotenv.load

$redis = Redis.new(url: ENV['REDIS_URL'])
$redis.flushall

ENV['PPAP_DEPLOY_KEY'] = SecureRandom.uuid if ENV['PPAP_DEPLOY_KEY'].nil?
ENV['PPAP_S_API_KEY'] = SecureRandom.uuid if ENV['PPAP_S_API_KEY'].nil?
ENV['PPAP_B_API_KEY'] = SecureRandom.uuid if ENV['PPAP_B_API_KEY'].nil?
ENV['PPAP_V_API_KEY'] = SecureRandom.uuid if ENV['PPAP_V_API_KEY'].nil?
ENV['PPAP_G_API_KEY'] = SecureRandom.uuid if ENV['PPAP_G_API_KEY'].nil?
ENV['PPAP_VOICE_API_KEY'] = SecureRandom.uuid if ENV['PPAP_VOICE_API_KEY'].nil?
ENV['PPAP_UNIQ_ID'] = SecureRandom.uuid if ENV['PPAP_UNIQ_ID'].nil?
ENV['PRIVACY_LEVEL'] = '0' if ENV['PRIVACY_LEVEL'].nil?

ENV['MAIL_MODE'] = 'false' if ENV['MAIL_MODE'].nil?
ENV['MAIL_API_KEY'] = '' if ENV['MAIL_API_KEY'].nil?
ENV['MAIL_API_URL'] = '' if ENV['MAIL_API_URL'].nil?
ENV['MAIL_FROM'] = '' if ENV['MAIL_FROM'].nil?
ENV['MAIL_TO'] = '' if ENV['MAIL_TO'].nil?

if File.exist?("secret/api-key.json")
  API_KEY = JSON.parse(File.open("secret/api-key.json").read)
else
  API_KEY = {
    'deploy' => ENV['PPAP_DEPLOY_KEY'],
    's' => ENV['PPAP_S_API_KEY'],
    'b' => ENV['PPAP_B_API_KEY'],
    'v' => ENV['PPAP_V_API_KEY'],
    'g' => ENV['PPAP_G_API_KEY'],
    'voice' => ENV['PPAP_VOICE_API_KEY'],
    'uniqid' => ENV['PPAP_UNIQ_ID'],
  }
end

PRIVACY_LEVEL = ENV['PRIVACY_LEVEL'].to_i
puts "PRIVACY_LEVEL: #{PRIVACY_LEVEL}" 

puts "API-KEY"
API_KEY.each do |server, key|
  puts "#{server}: #{key}"
end

SERVERS = ['s', 'b', 'v', 'g']

$web_clients = []

$spool_data = {
  'v' => [],
  'b' => [],
  's' => [],
  'g' => [],
}

$lock = {
  'v' => false,
  'b' => false, 
  's' => false,
  'g' => false,
  'all' => false,
}

$search_stack = {
  'v' => 0,
  'b' => 0, 
  's' => 0,
  'g' => 0,
  'all' => 0,
}

$search_max = {
  'v' => 5,
  'b' => 5, 
  's' => 5,
  'g' => 5,
  'all' => 5,
}

$store_audio = []
$form_us = ""
$form_us_time = Time.now - 180
$push_flg = false

require_relative 'lib/push'
require_relative 'lib/papamira'
