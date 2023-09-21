# -*- encoding: utf-8 -*-

module Papamira
  class App < Sinatra::Base

    @@papi = Papamira_API.new

    require_relative 'preload'

    set :public_folder, "public"
    set :views, "views"
    enable :sessions
    helpers Sinatra::Cookies

    require_relative 'helper'
    require_relative 'mail'
    require_relative 'route'
    require_relative 'worker'

  end
end
