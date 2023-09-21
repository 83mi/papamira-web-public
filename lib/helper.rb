# -*- encoding: utf-8 -*-

module Papamira
  class App < Sinatra::Base

    helpers do
      def lock(server="")
        if server.empty?
          return $lock
        else
          return $lock[server]
        end
      end

      def set_lock(server="", flg=true)
        if server.empty?
          false
        else
          $lock[server] = flg
          true
        end
      end

      def spool(server="")
        if server.empty?
          return $spool_data
        else
          return $spool_data[server]
        end
      end

      def search_word_save(server, word)
        word = URI.unescape(word).toutf8
        p "Server: #{server}"
        p "SearchWord: " + word

        if PapamiraSearchWord.where(server: server).size != 0
          pDB = PapamiraSearchWord.find_by(server: server)
          body_in = JSON.parse(pDB[:data])

          body_flg = true
          body_in.each do |body|
            if body['body'] == word
              body['count'] += 1
              body_flg = false
              break
            end
          end

          if body_flg
            body_in.push(
              {'body' => word, 
               'count' => 1,
              }
            )
          end

          pDB.update(
            server: server,
            data: JSON.generate(body_in),
          )
          pDB.save
        else
          search_data = []
          search_data.push(
            {'body' => word, 
             'count' => 1,
            }
          )
          pDB = PapamiraSearchWord.new(
            :server => server,
            :data => JSON.generate(search_data),
          )
          pDB.save
        end
        ""
      end

      def disable_host
        stat = false
        if File.exist?("secret/disable-host.json")
          disable_list = JSON.parse(File.open("secret/disable-host.json").read)
        else
          if ENV['PPAP_DISABLE_HOST'].nil?
            disable_list = ["192.168.1", "127.0.0.1", "localhost"]
          else
            disable_list = ENV['PPAP_DISABLE_HOST'].split(/,/)
          end
        end

        disable_list.each do |url|
          if request.env['HTTP_X_FORWARDED_FOR'].to_s
            if /#{url}/ =~ request.env['HTTP_X_FORWARDED_FOR'].to_s
              stat = true
              break
            else
              stat = false
            end
          end
          if request.env['REMOTE_ADDR'].to_s
            if /#{url}/ =~ request.env['REMOTE_ADDR'].to_s
              stat = true
              break
            else
              stat = false
            end
          end
        end

        stat = false if request.env['REQUEST_PATH'] == '/'
        stat = false if request.env['REQUEST_PATH'] == '/help'
        stat = false if request.env['REQUEST_PATH'] == '/form'
        stat = false if request.env['REQUEST_PATH'] == '/form_confirm'
        stat = false if request.env['REQUEST_PATH'] == '/form_post'

        return stat
      end

      def disable_host_ex
        stat = false
        if File.exist?("secret/disable-host.json")
          disable_list = JSON.parse(File.open("secret/disable-host.json").read)
        else
          if ENV['PPAP_DISABLE_HOST'].nil?
            disable_list = ["192.168.1", "127.0.0.1", "localhost"]
          else
            disable_list = ENV['PPAP_DISABLE_HOST'].split(/,/)
          end
        end

        disable_list.each do |url|
          if request.env['HTTP_X_FORWARDED_FOR'].to_s
            if /#{url}/ =~ request.env['HTTP_X_FORWARDED_FOR'].to_s
              stat = true
              break
            else
              stat = false
            end
          end
          if request.env['REMOTE_ADDR'].to_s
            if /#{url}/ =~ request.env['REMOTE_ADDR'].to_s
              stat = true
              break
            else
              stat = false
            end
          end
        end
        stat
      end

      def push_itemdrop(params)
        if PapamiraItemdrop.size == 0
          data = []
          data.push(params)
          itemdrops = JSON.generate(data)

          pDB = PapamiraItemdrop.new(
            :data=> itemdrops
          )
          pDB.save

          ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
          GC.start
        else
          retry_count = 0
          begin
            fetch_data = []
            fetch_flg = false

            pDB = PapamiraItemdrop.all
            pDB.each do |ppDB|
              itemdrops = ppDB[:data]
              data = JSON.parse(itemdrops)

              data.each do |d|
                if params['uuid'] == d['uuid']
                  # check
                  d['data'] = params['data']
                  fetch_flg = true
                end
                fetch_data.push(d)
              end
            end

            fetch_data.push(params) unless fetch_flg
            itemdatas = JSON.generate(fetch_data)

            pDB.update(data: itemdatas)

            ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
            GC.start
          rescue => e
            retry_count += 1
            sleep 1.0
            if retry_count < 5
              puts "Error: 書き込み失敗"
              puts e.to_s
              puts "body: " + params.to_s
              retry
            end
          end
        end

        return true
      end

      def push_shop(params)
        days = Date.parse(DateTime.now.to_s).to_s

        unless PapamiraYourshop.where(date: days).size == 0
          retry_count = 0
          begin
            pDB = PapamiraYourshop.find_by(date: days)
            shop_data_in = pDB[:data]
            data = JSON.parse(shop_data_in)

            flg = false
            data.each do |d|
              flg = true if params['uuid'] == d['uuid']
            end

            if flg
              data.push(params)
              shop_data_out = JSON.generate(data)

              pDB.update(
                date: days,
                data: shop_data_out,
              )
              pDB.save

              ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
              GC.start
            end
          rescue => e
            retry_count += 1
            sleep 1.0
            if retry_count < 5
              puts "Error: 書き込み失敗"
              puts e.to_s
              puts "body: " + params.to_s
              retry
            end
          end
        end

        return true
      end

      def push_defalut(server, params)
        marge_flg = false
        if params['key'].to_s == API_KEY[server]

          uid = 0
          retry_count = 0
          begin
            days = Date.parse(params['date']).to_s.gsub(/-/, "/")
            date = params['date']
            stat = params['stat']
            name = params['name']
            shout_data = params['body']

            pDB = PapamiraShout.new(
              :stat => stat,
              :server => server,
              :days => days,
              :date => date,
              :name => name,
              :body => shout_data,
            )
            pDB.save
          rescue
            retry_count += 1
            sleep 5.0
            if retry_count < 10
              puts "Error: 書き込み失敗"
              puts "body: " + params.to_s
              retry
            end
          end

          uid = PapamiraShout.select(:id).maximum(:id)
          params['id'] = uid.to_s

          SERVERS.each do |re_server|
            if server == re_server
              hekey = "history_shout_" + re_server
              rekey = "shout_" + re_server
              sekey = 'top_server_active:' + re_server
              
              if $redis.exists(rekey) != 0
                cparams = params.dup
                cparams['server'] = server
                cparams['key'] = ''
                cparams['page'] = ''
                cparams['search_name'] = ''
                cparams['search_body'] = ''
                cparams.delete('key')
                cparams.delete('page')
                cparams.delete('search_name')
                cparams.delete('search_body')

                $redis.rpop(rekey)
                $redis.lpush(rekey, JSON.generate(cparams))
                $redis.expire(rekey, 6000)
              end

              if $redis.exists(hekey) != 0
                cparams = params.dup
                cparams['server'] = server
                cparams['key'] = ''
                cparams['page'] = ''
                cparams['search_name'] = ''
                cparams['search_body'] = ''
                cparams.delete('key')
                cparams.delete('page')
                cparams.delete('search_name')
                cparams.delete('search_body')

                $redis.rpop(hekey)
                $redis.lpush(hekey, JSON.generate(cparams))
                $redis.expire(hekey, 3600)
              end

              $redis.set(sekey, "up")
              $redis.expire(sekey, 3600)
              break
            end
          end

          allkey = "top_server_active:all"
          ac = []
          ac.push($redis.get('top_server_active:s'))
          ac.push($redis.get('top_server_active:v'))
          ac.push($redis.get('top_server_active:b'))
          ac.push($redis.get('top_server_active:g'))

          scount = 0
          ac.each do |v|
            scount+=1 if v == 'up'
          end
          $redis.set(allkey, scount)
          $redis.expire(allkey, 3600)

          if $redis.exists("all_shout") != 0
            cparams = params.dup
            cparams['server'] = server
            cparams['key'] = ''
            cparams['page'] = ''
            cparams['search_name'] = ''
            cparams['search_body'] = ''
            cparams.delete('key')
            cparams.delete('page')
            cparams.delete('search_name')
            cparams.delete('search_body')

            $redis.rpop("all_shout")
            $redis.lpush("all_shout", JSON.generate(cparams))
            $redis.expire("all_shout", 6000)
          else
            @@papi.all_shout
          end

          if $redis.exists("top_shout") != 0
            cparams = params.dup
            cparams['server'] = server
            cparams['key'] = ''
            cparams['page'] = ''
            cparams['search_name'] = ''
            cparams['search_body'] = ''
            cparams.delete('key')
            cparams.delete('page')
            cparams.delete('search_name')
            cparams.delete('search_body')

            $redis.rpop("top_shout")
            $redis.lpush("top_shout", JSON.generate(cparams))
            $redis.expire("top_shout", 6000)
          else
            @@papi.top_shout
          end

          if $redis.exists("top_now_shout") != 0
            cparams = params.dup
            cparams['key'] = ''
            cparams['page'] = ''
            cparams.delete('key')
            cparams.delete('page')

            body = cparams['body']
            $redis.set("top_now_shout", body)
            $redis.expire("top_now_shout", 6000)
          else
            @@papi.now_shout
          end

          if lock(server) == false
            $redis.del("server_active_render")
            $redis.del(server + "_now")
            $redis.del(server + "_now_m")
            $redis.del("shout_days_" + server + "_1")
            $redis.del("shout_days_" + server + "_2")
            $redis.del("shout_days_" + server + "_3")
            $redis.del("shout_days_" + server + "_7")
            $redis.del("shout_days_" + server + "_14")
            $redis.del("shout_days_" + server + "_30")

            params['search_name'] = NKF.nkf("-Xwm0Z1", (params['name']).upcase)
            params['search_body'] = NKF.nkf("-Xwm0Z1", (params['body']).upcase)

            PapamiraPusher.push_sync(params, $web_clients)

            ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
            GC.start
          else
            spool(server).push( { "render" => params } )
          end

          marge_flg = true
        end
        return marge_flg
      end

      def run_deploy
        marge_flg = false

        PapamiraShout.destroy_all
        ActiveRecord::Base.connection.execute("select setval ('papamira_shouts_id_seq', 1, false)")

        pDB = PapamiraWorld.where(tags: 'day')
        pDB.order(days: :asc).each do |dbs|
          server = dbs[:server]
          JSON.parse(dbs[:body]).each do |data|
            days = data['date'].split(/ /).first.to_s
            begin
              nDB = PapamiraShout.new(
                :stat => data['stat'],
                :server => server,
                :days => days,
                :date => data['date'],
                :name => data['name'].gsub(/\u0000/, ""),
                :body => data['body'].gsub(/\u0000/, ""),
              )
              nDB.save
            rescue => e
              p e
              p "DB: write error."
              marge_flg = nil
              break
            end
          end
          break if marge_flg.nil?
        end

        if marge_flg.nil?
          marge_flg = false
        else
          marge_flg = true
        end

        return marge_flg
      end

      def server_active
        JSON.parse(@@papi.server_active)
      end

      def server_active_render
        key = 'server_active_render'
        sa = {}

        if $redis.exists(key)
          self.server_active.each do |s, stat|
            case stat
            when "up"
              sa[s] = "<b class=\"badge badge-primary\">#{stat.upcase}</b>"
            when "down"
              sa[s] = "<b class=\"badge badge-warning\">#{stat.upcase}</b>"
            else
              case stat
              when 0
                sa[s] = "<b class=\"badge badge-danger\">#{stat}鯖UP</b>"
              when 1
                sa[s] = "<b class=\"badge badge-warning\">#{stat}鯖UP</b>"
              when 2
                sa[s] = "<b class=\"badge badge-info\">#{stat}鯖UP</b>"
              when 3
                sa[s] = "<b class=\"badge badge-primary\">#{stat}鯖UP</b>"
              when 4
                sa[s] = "<b class=\"badge badge-primary\">#{stat}鯖UP</b>"
              else
                sa[s] = "<b class=\"badge badge-danger\">不明</b>"
              end
            end
          end
          $redis.hset(key, sa)
          $redis.expire(key, 300)
        else
          sa = $redis.hgetall(key)
        end
        return sa
      end

      def chat_check(name, text)
        flg = false
        if text.size <= 40 and text.size != 0
          if name.size <= 20 and name.size != 0
            flg = true
          end
        end
        flg
      end

      def chat_people
        web_peoples = 0
        dep_flg = false
        $web_clients.each do |client| 
          case client.env['REQUEST_URI']
          when /^\/(s|b|v|g|all)\/stream$/
            if dep_flg
              dep_flg = false
            else
              dep_flg = true
              web_peoples += 1
            end
          when /^\/(s|b|v|g)\/ppap$/
            web_peoples += 1
          else
            web_peoples += 1
          end
        end
        web_peoples += 1
        return web_peoples
      end

      def chat_get
        ckey = "chat_data"
        ref = []

        if $redis.exists(ckey) == 0
          JSON.parse(@@papi.get_webchat).each do |data|
            cd = %Q!<span class="badge badge-dark">#{data['name']}</span>: <span class="small">#{data['data']}</span><br>!
            ref.push(cd)
            $redis.rpush(ckey, cd)
          end
          $redis.expire(ckey, 3600*24)
        else
          ref = $redis.lrange(ckey, 0, 1000)
        end

        return ref.join("\n")
      end

      def form_output(params)
        req_uid = DateTime.now.strftime("%Y%m%d_%H%M%S_") + SecureRandom.uuid
        params[:req_uid] = req_uid.to_s

        puts "-----------------------------------------------"
        puts "お問い合わせ[Contact Us]"
        puts "ID: "+ params[:req_uid].to_s
        puts "-----------------------------------------------"
        puts "From1: " + request.env['HTTP_X_FORWARDED_FOR'].to_s
        puts "From2: " + request.env['REMOTE_ADDR'].to_s
        puts "Agent: " + request.env['HTTP_USER_AGENT'].to_s
        puts "-----------------------------------------------"
        puts "Name: " + params[:f_name].toutf8
        puts "Mail: " + params[:f_mail].toutf8
        puts "Subject: " + params[:f_subject].toutf8
        puts "-----------------------------------------------"
        puts "Text: " + params[:f_text].toutf8
        puts "-----------------------------------------------"

        if ENV['RACK_ENV'] == 'production' and ENV['MAIL_MODE'].to_s == "true"
          mail_send(params)
        end

        return req_uid
      end
    end

  end
end
