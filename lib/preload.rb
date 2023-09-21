# -*- encoding: utf-8 -*-
# DB preload
#

module Papamira
  class App < Sinatra::Base
    @@papi.history_shout({:server => 's'})
    pp "preload: s_shout"
    @@papi.history_shout({:server => 'v'})
    pp "preload: v_shout"
    @@papi.history_shout({:server => 'b'})
    pp "preload: b_shout"
    @@papi.history_shout({:server => 'g'})
    pp "preload: g_shout"
    @@papi.all_shout
    pp "preload: all_shout"
    @@papi.top_shout
    pp "preload: top_shout"
    @@papi.now_shout
    pp "preload: now_shout"
    @@papi.words
    pp "preload: words"
  end
end
