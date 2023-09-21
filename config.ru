require 'rubygems'
require './app.rb'
require './lib/websocket/backend'

use Papamira::Backend
Faye::WebSocket.load_adapter('thin')

run Papamira::App

# Thraed Worker
require './lib/worker'
