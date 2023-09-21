require 'faye/websocket'
require 'json'

module Papamira
  class Backend
    KEEPALIVE_TIME = 60
    def initialize(app)
      @app = app
      $web_clients = []
    end

    def call(env)
      if Faye::WebSocket.websocket?(env)
        ws = Faye::WebSocket.new(env, nil, ping: KEEPALIVE_TIME)
        
        ws.on :open do |event|
          pp [:open, ws.object_id] if ENV['RACK_ENV'] == 'development'
          $web_clients << ws
          # ws.send({ you: ws.object_id }.to_json)
        end

        ws.on :message do |event|
          p [:message, event.data]
          $web_clients.each { |client| 
            client.send event.data
          }
        end

        ws.on :close do |event|
          pp [:close, ws.object_id, event.code] if ENV['RACK_ENV'] == 'development'
          $web_clients.delete(ws)
          ws = nil
        end

        ws.rack_response
      else
        @app.call(env)
      end
    end
  end
end
