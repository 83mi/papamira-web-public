# -*- encoding: utf-8 -*-

module Papamira
  class App < Sinatra::Base

    before do
      # HTTPS redirect
      if request.env['REMOTE_ADDR'] != '127.0.0.1' && request.scheme != 'https' && ENV['RACK_ENV'] != 'development'
        if /^192.168.(0|1)./ !~ request.env['REMOTE_ADDR'] && ENV['RACK_ENV'] != 'development'
          redirect "https://#{request.env['HTTP_HOST']}"
        end
      end

      if ENV['RACK_ENV'] != 'test'
        if /^\/(keepalive|push2|store\/|api\/)/ !~ request.env['REQUEST_URI'].to_s
          p "Logs:"
          p "  URI:"+request.env['REQUEST_URI'].to_s
        end

        if /(^\/$)|(^\/(s|b|v|g|all)\/(stream|ppap)$)/ =~ request.env['REQUEST_URI'].to_s
          p "Logs:"
          if request.env['HTTP_X_FORWARDED_FOR'].to_s == ""
            p "  IP: " + request.env['REMOTE_ADDR'].to_s
          else
            p "  IP: " + request.env['HTTP_X_FORWARDED_FOR'].to_s
          end
          p "  AGENT: " + request.env['HTTP_USER_AGENT'].to_s
        end
      end

      # redirect 'https://www.yahoo.co.jp/', 301 if self.disable_host
      if self.disable_host_ex
        redirect 'https://www.yahoo.co.jp/', 301
      else
        redirect '/' if self.disable_host
      end
    end

    after do
      ActiveRecord::Base.connection.close
      # redirect 'https://www.yahoo.co.jp/', 301 if self.disable_host
      if self.disable_host_ex
        redirect 'https://www.yahoo.co.jp/', 301
      else
        redirect '/' if self.disable_host
      end
    end

    post '/push_test', provides: :json do 
      status 502
    end

    post '/push2', provides: :json do
      marge_flg = false
      params = JSON.parse(request.body.read)
      stat = params['stat']

      case stat
      when /^(wt|sh)$/
        case params['key'].to_s
        when API_KEY['v']
          marge_flg = push_defalut('v', params)
        when API_KEY['b']
          marge_flg = push_defalut('b', params)
        when API_KEY['s']
          marge_flg = push_defalut('s', params)
        when API_KEY['g']
          marge_flg = push_defalut('g', params)
        end
      when "deploy"
        if params['key'].to_s == API_KEY['deploy']
          marge_flg = run_deploy
        end
      end
      marge_flg.to_s
    end
 
    post '/push_days', provides: :json do
      marge_flg = false
      params = JSON.parse(request.body.read)
      case params['key'].to_s
      when API_KEY['v']
        marge_flg = push_days_defalut('v', params)
      when API_KEY['b']
        marge_flg = push_days_defalut('b', params)
      when API_KEY['s']
        marge_flg = push_days_defalut('s', params)
      when API_KEY['g']
        marge_flg = push_days_defalut('g', params)
      end
      marge_flg.to_s
    end

    post %r{/(v|b|s|g)/lock}, provides: :json do |server|
      if params['key'].to_s == API_KEY[server]
        set_lock(server, true)
      end
    end

    post %r{/(v|b|s|g)/unlock}, provides: :json do |server|
      if params['key'].to_s == API_KEY[server]
        set_lock(server, false)
      end
    end

    get '/' do
      @power = JSON.parse(@@papi.server_power)
      @server_version = Papamira_Status.Version
      @first_update = Papamira_Status.Init
      @last_update = Papamira_Status.Update

      template = ""
      JSON.parse(@@papi.top_shout).each_with_index do |data, index|
        template += "<tr><td>#{data['body']}</td></tr>";
        break if index >= 4
      end
      @body = template

      erb :top
    end

    get '/top' do
      @s = self.server_active_render()
      @release_note = Papamira_Doc.ReleaseNote
      erb :top_menu
    end

    get '/keepalive' do
      return ""
    end

    get '/feature' do
      markdown :fake
    end

    get %r!/ss/(\d+)! do |id|
      params = {}
      params[:id] = id

      jdata = JSON.parse(@@papi.select_shout_for_id(params))

      @body = ""
      unless jdata.empty?
        jdata.each do |data|
          @body << "<tr>"
          @body << "<td>"
          @body << "<div>"

          case data['server']
          when 's'
            @body << '<span class="badge badge-danger">S</span>'
          when 'b'
            @body << '<span class="badge badge-primary">B</span>'
          when 'v'
            @body << '<span class="badge badge-warning">V</span>'
          when 'g'
            @body << '<span class="badge badge-secondary">G</span>'
          end
          @body << "</div>"

          @body << "</td>"
          @body << "<td>"
          @body << '<div class="text-nowrap fixed">'
          @body << data['date']
          @body << '</div>'
          @body << "</td>"
          @body << "<td>"
          @body << '<div class="text-nowrap fixed">'
          @body << data['name']
          @body << '</div>'
          @body << "</td>"
          @body << "<td>"
          @body << '<div>'
          @body << data['body']
          @body << '</div>'
          @body << "</td>"
          @body << "</tr>"
          @body << "\n"
        end
      else
        @body = ""
      end

      erb :select_name_plus
    end

    get %r!/(v|b|s|g)/(select_shout|ss)/(\d{4})/(\d{2})/(\d{2})/(([0-9]|-|,)+)! do |server, url, y, m, d, pages, page|
      params = {}
      params[:server] = server
      params[:day] = [y, m, d, pages].join("-")
      jdata = JSON.parse(@@papi.select_shout(params))

      @body = ""
      if not jdata.empty?
        jdata.each do |data|
          @body << "<tr>"
          @body << "<td>"
          @body << "<div>"

          case data['server']
          when 's'
            @body << '<span class="badge badge-danger">S</span>'
          when 'b'
            @body << '<span class="badge badge-primary">B</span>'
          when 'v'
            @body << '<span class="badge badge-warning">V</span>'
          when 'g'
            @body << '<span class="badge badge-secondary">G</span>'
          end
          @body << "</div>"

          @body << "</td>"
          @body << "<td>"
          @body << '<div class="text-nowrap fixed">'
          @body << data['date']
          @body << '</div>'
          @body << "</td>"
          @body << "<td>"
          @body << '<div class="text-nowrap fixed">'
          @body << data['name']
          @body << '</div>'
          @body << "</td>"
          @body << "<td>"
          @body << '<div>'
          @body << data['body']
          @body << '</div>'
          @body << "</td>"
          @body << "</tr>"
          @body << "\n"
        end
      else
        @body = ""
      end
      erb :select_shout #, :layout => :plane
    end

    get %r!/(v|b|s|g)/(select_day|ss)/(\d{4})/(\d{2})/(\d{2})! do |server, url, y, m, d|
      params = {}
      params[:server] = server
      params[:day] = [y, m, d].join("-")
      uniq_id = cookies[:papamira_uniq_id]

      jdata = JSON.parse(@@papi.select_day(params, uniq_id))

      @body = ""
      unless jdata.empty?
        jdata.each do |data|
          @body << "<tr>"
          @body << "<td>"

          case data['server']
          when 's'
            @body << '<span class="badge badge-danger">S</span>'
          when 'b'
            @body << '<span class="badge badge-primary">B</span>'
          when 'v'
            @body << '<span class="badge badge-warning">V</span>'
          when 'g'
            @body << '<span class="badge badge-secondary">G</span>'
          end

          @body << "</td>"
          @body << "<td>"
          @body << data['date']
          @body << "</td>"
          @body << "<td>"
          @body << data['name']
          @body << "</td>"
          @body << "<td>"
          @body << data['body']
          @body << "</td>"
          @body << "</tr>"
          @body << "\n"
        end
      else
        @body = ""
      end

      erb :select_day
    end

    get %r{/(v|b|s|g)/ppap} do |server|
      @title_server = server.to_s.upcase
      @chat_people = chat_people()
      @chat_body = chat_get
      erb :ppap
    end

    get %r{/(v|b|s|g)/stream} do |server|
      @title_server = server.to_s.upcase
      @chat_people = chat_people()
      @chat_body = chat_get
      erb :stream
    end

    get "/all/stream" do
      @chat_people = chat_people()
      @chat_body = chat_get
      erb :all_stream
    end

    get '/info' do
      erb :info_all
    end

    get '/info_wdays' do
      erb :info_wdays
    end

    get '/info_calendar' do
      erb :info_calendar
    end

    get %r{/(v|b|s|g)/info} do |server|
      erb :info
    end

    get '/chat_send' do
      @chat_flg = false
      data = {}
      data['name'] = CGI.escapeHTML(params[:chat_name].to_s)
      data['text'] = CGI.escapeHTML(params[:chat_text].to_s)
      data['uid'] = SecureRandom.uuid

      if chat_check(data['name'], data['text'])
        data['host'] = request.env['REMOTE_ADDR'].to_s
        data['date'] = Time.now.to_s
        lpDB = PapamiraChat.last

        if lpDB.nil?
          pDB = PapamiraChat.new(
            :name => data['name'],
            :body => data['text'],
            :host => data['host'],
            :time => data['date'],
          )
          pDB.save

          params2 = {}
          params2['mode'] = 'chat'
          params2['name'] = data['name']
          params2['body'] = data['text']
          params2['uid'] = data['uid']
          jparams = JSON.generate(params2)

         while @chat_flg do
           sleep 0.5
         end

          $web_clients.each { |client|
            @chat_flg = true
            client.send(jparams)
          }
          @chat_flg = false

          if $redis.exists("chat_data") != 0
            cd = %Q!<span class="badge badge-dark">#{data['name']}</span>: <span class="small">#{data['text']}</span><br>!
            $redis.rpop("chat_data")
            $redis.lpush("chat_data", cd)
          end
          $redis.del("chat_data_raw")

          pp [:chat, data['date'], data['text']]
        else
          if lpDB.body != data['text']
            pDB = PapamiraChat.new(
              :name => data['name'],
              :body => data['text'],
              :host => data['host'],
              :time => data['date'],
            )
            pDB.save
            if PapamiraChat.count > 100
              fpDB = PapamiraChat.first
              fpDB.delete
            end

            params2 = {}
            params2['mode'] = 'chat'
            params2['name'] = data['name']
            params2['body'] = data['text']
            params2['uid'] = data['uid']
            jparams = JSON.generate(params2)

            sleep 0.5 if @chat_flg
            $web_clients.each { |client|
              @chat_flg = true
              client.send(jparams)
            }
            @chat_flg = false

            if $redis.exists("chat_data") != 0
              cd = %Q!<span class="badge badge-dark">#{data['name']}</span>: <span class="small">#{data['text']}</span><br>!
              $redis.rpop("chat_data")
              $redis.lpush("chat_data", cd)
            end
            $redis.del("chat_data_raw")

            pp [:chat, data['date'], data['text']]
          end
        end
      end
      ""
    end

    get '/ranking' do
      erb :ranking
    end

    get '/words' do
      erb :words
    end

    get %r{/store/([\w]+)} do |voice|
      send_file '/tmp/' + voice + '.mp3', :filename => voice
    end

    get '/form' do
      if (Time.now - $form_us_time) >= 180
        session = cookies['rack.session']
        $redis.hset("form_session", session, "true")
        $redis.expire("form_session", 1200)
        @session = session
        erb :form
      else
        @user_error = "時間を空けてから投稿してください。<br>連続した投稿は出来ません。"
        erb :form_error
      end
    end

    post '/form' do
      @session = params[:f_session]
      @user_name  = params[:f_name].toutf8
      @user_email = params[:f_mail].toutf8
      @user_subject = params[:f_subject].toutf8
      @user_text = params[:f_text].toutf8
      erb :form
    end

    post '/form_confirm' do
      @session = params[:f_session]
      @user_name  = params[:f_name].toutf8
      @user_email = params[:f_mail].toutf8
      @user_subject = params[:f_subject].toutf8
      @user_text = params[:f_text].toutf8
      @user_error = ""

      if !$redis.hget("form_session", @session).nil?
        if !@user_name.empty? and !@user_email.empty? and !@user_text.empty?
          if $redis.hget("form_session", @session) == "true"
            @user_error = "時間を空けてから投稿してください。<br>連続した投稿は出来ません。"
            if $form_us.empty?
              erb :form_confirm
            else
              if request.env['HTTP_X_FORWARDED_FOR'].to_s.empty?
                if $form_us != request.env['REMOTE_ADDR'].to_s
                  erb :form_confirm
                else
                  if (Time.now - $form_us_time) >= 180
                    erb :form_confirm
                  else
                    erb :form_error
                  end
                end
              else
                if $form_us != request.env['HTTP_X_FORWARDED_FOR'].to_s.split(/,/).last
                  erb :form_confirm
                else
                  if (Time.now - $form_us_time) >= 180
                    erb :form_confirm
                  else
                    erb :form_error
                  end
                end
              end
            end
          else
            @session = ""
            @user_error = "不正なセッションです"
            erb :form_error
          end
        else
          @user_error = "必須項目に未記入があります"
          erb :form_error
        end
      else
        $redis.del("form_session", @session)
        @session = ""
        @user_error = "不正なセッションです"
        erb :form_error
      end
    end

    post '/form_post' do
      @session = params[:f_session]
      @user_name  = params[:f_name].toutf8
      @user_email = params[:f_mail].toutf8
      @user_text = params[:f_text].toutf8
      @user_error = ""

      if !@user_name.empty? and !@user_email.empty? and !@user_text.empty? and !@session.empty?
        @user_error = "時間を空けてから投稿してください。<br>連続した投稿は出来ません。"
        if $form_us.empty?
          @req_uid = form_output(params)
          if request.env['HTTP_X_FORWARDED_FOR'].to_s.empty?
            $form_us = request.env['REMOTE_ADDR'].to_s
          else
            $form_us = request.env['HTTP_X_FORWARDED_FOR'].to_s.split(/,/).last
          end
          $form_us_time = Time.now
          $redis.del("form_session", @session)
          @session = ""
          erb :form_post
        else
          if request.env['HTTP_X_FORWARDED_FOR'].to_s.empty?
            if $form_us != request.env['REMOTE_ADDR'].to_s
              @req_uid = form_output(params)
              $form_us = request.env['REMOTE_ADDR'].to_s
              $form_us_time = Time.now
              $redis.del("form_session", @sessoin)
              @session = ""
              erb :form_post
            else
              if (Time.now - $form_us_time) >= 180
                @req_uid = form_output(params)
                $form_us = request.env['REMOTE_ADDR'].to_s
                $form_us_time = Time.now
                $redis.del("form_session", @sessoin)
                @session = ""
                erb :form_post
              else
                erb :form_error
              end
            end
          else
            if $form_us != request.env['HTTP_X_FORWARDED_FOR'].to_s.split(/,/).last
              @req_uid = form_output(params)
              $form_us = request.env['HTTP_X_FORWARDED_FOR'].to_s.split(/,/).last
              $form_us_time = Time.now
              $redis.del("form_session", @sessoin)
              @session = ""
              erb :form_post
            else
              if (Time.now - $form_us_time) >= 180
                @req_uid = form_output(params)
                $form_us = request.env['HTTP_X_FORWARDED_FOR'].to_s.split(/,/).last
                $form_us_time = Time.now
                $redis.del("form_session", @sessoin)
                @session = ""
                erb :form_post
              else
                erb :form_error
              end
            end
          end
        end
      else
        @user_error = "必須項目に未記入があります"
        erb :form_error
      end
    end

    get '/update' do
      @release_noteold = Papamira_Doc.ReleaseNoteOld
      erb :update
    end

    get '/testing' do
      erb :testing
    end

    get '/gui' do
      erb :gui
    end

    get '/gui/update' do
      erb :gui_update
    end

    get '/help' do
      erb :help
    end

    get '/dev' do
      @server_version = Papamira_Status.Version
      if File.exist?("README.md")
        @readme = File.open("README.md").read.gsub(/\n/, "<br>\n")
      else
        @readme = ""
      end
      erb :dev
    end

    get '/source' do
      erb :source
    end

    get '/download/lib' do
      send_file 'middle/shout.rb', :filename => 'papamira.rb'
    end

    get '/download/web' do
      send_file 'middle/web_v8.2.0.zip', :filename => 'papamira-web_v8.2.0.zip'
    end

    get '/download/web_old' do
      send_file 'middle/web_v6.6.10.zip', :filename => 'papamira-web_v6.6.10.zip'
    end

    get %r!/your_shop/(\w{64})! do |uurl|
      uniq_pass = cookies[:papamira_shop_pass]
      @shop_data = @@papi.get_cloudshop_report(uurl, uniq_pass)
      erb :your_shop
    end

    post %r!/your_shop/\w{64}/post!, provides: :json do
      params = JSON.parse(request.body.read)
      push_shop(params)
    end

    get %r!/(api|api/)! do
      erb :api
    end

    get '/api/v1/get_webchat', provides: :json do
      @@papi.get_webchat
    end

    get '/api/v1/get_itemdrop', provides: :json do
      @@papi.get_itemdrops
    end

    post '/api/v1/push_itemdrop', provides: :json do
      params = JSON.parse(request.body.read)
      push_itemdrop(params)
    end

    get '/api/v1/get_shop', provides: :json do
      @@papi.get_cloudshop(params)
    end

    get '/api/v1/random_shout', provides: :json do
      @@papi.random_shout
    end

    get '/api/v1/shout', provides: :json do
      @@papi.shout(params)
    end

    get '/api/v1/shout_days', provides: :json do
      @@papi.shout_days(params)
    end
    
    get '/api/v1/history_shout', provides: :json do
      @@papi.history_shout(params)
    end

    get '/api/v1/all_shout', provides: :json do
      @@papi.all_shout
    end

    get '/api/v1/select_day', provides: :json do
      uniq_id = cookies[:papamira_uniq_id]
      @@papi.select_day(params, uniq_id)
    end

    get '/api/v1/select_shout', provides: :json do
      @@papi.select_shout(params)
    end

    get '/api/v1/autocomplete', provides: :json do
      @@papi.autocomplete(params)
    end

    get '/api/v1/user_search_word', provides: :json do
      @@papi.user_search_word(params)
    end

    get '/api/v1/search_shout', provides: :json do
      @@papi.search_shout(params)
    end

    get '/api/v2/search_shout', provides: :json do
      @@papi.search_shout_v2(params)
    end

    get '/api/v1/search_tags', provides: :json do
      @@papi.search_tags(params)
    end

    get '/api/v1/1day_shout', provides: :json do
      @@papi._1day_shout(params)
    end

    get '/api/v1/info_server', provides: :json do
      @@papi.graph_server(params)
    end

    get '/api/v1/info_day', provides: :json do
      @@papi.graph_days(params)
    end

    get '/api/v1/info_wday', provides: :json do
      @@papi.graph_wdays(params)
    end

    get '/api/v1/info_calendar', provides: :json do
      @@papi.graph_select_day(params)
    end

    get '/api/v1/ranking', provides: :json do
      @@papi.ranking()
    end

    get '/api/v1/words', provides: :json do
      @@papi.words()
    end

    get '/api/v1/select_history_words', provides: :json do
      @@papi.select_history_words(params)
    end

    get '/api/v1/server_active', provides: :json do
      @@papi.server_active()
    end

    get '/api/v1/web_connect_int', provides: :json do
      @@papi.all_web_connect
    end

    get '/api/v1/web_connect', provides: :json do
      @@papi.web_connect(params)
    end

    get '/api/v1/web_connects', provides: :json do
      @@papi.web_connects
    end

    get '/api/v1/server_alive', provides: :json do
      @@papi.server_alive(params)
    end

    get '/api/v1/server_power', provides: :json do
      @@papi.server_power
    end

    get '/api/v1/voice_dic', provides: :json do
      @@papi.voice_dic
    end

    get '/api/v1/ppap_shout', provides: :json do
      ppap = JSON.parse(File.open('data/ppap.dic').read)
      JSON.generate(ppap[rand(0..ppap.size)])
    end

    get '/api/v1/version', provides: :json do
      JSON.generate(Papamira_Status.Version)
    end

    error 404 do
      if env["REQUEST_PATH"].nil?
        puts 'not found:'
      else
        puts 'not found: ' + env["REQUEST_PATH"]
      end
      return '404'
    end
  end
end
