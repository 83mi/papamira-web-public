class Papamira_API

  require 'json'
  require 'nkf'
  require 'openssl'

  def lock(server="")
    if server.empty?
      return $lock
    else
      return $lock[server]
    end
  end

  def render_popup
    template_body = "update.."
    return template_body
  end

  def render_wait_search
    template_body = "お腹いっぱいです しばらく待って検索してね."
    return template_body
  end

  def get_webchat
    res = []
    key = "chat_data_raw"
    if $redis.exists(key) == 0
      PapamiraChat.select(:name, :body).reverse_each do |data|
        chat = {}
        chat['name'] = data[:name]
        chat['data'] = data[:body]
        res.push(chat)
        $redis.rpush(key, JSON.generate(chat))
      end
      $redis.expire(key, 3600*24)
    else
      $redis.lrange(key, 0, 1000).each do |_res|
        res.push(JSON.parse(_res))
      end
    end
    return JSON.generate(res)
  end

  def num_search(word)
    res = ""
    word.split(/\s/).each do |t|
      if /(\S*)\[(\d+\.*\d*)-(\d+\.*\d*),*(\d*)\](\S*)/ =~ t
        w,x,y,r,z = t.scan(/(\S*)\[(\d+\.*\d*)-(\d+\.*\d*),*(\d*)\](\S*)/).flatten
        if !x.nil? and !y.nil?
          p "SearchParameter: " + t
          if x >= y
            a = y.to_f
            b = x.to_f
          else
            a = x.to_f
            b = y.to_f
          end
          z = "[^\\d]" if z.nil? or z.empty?
          w = "[^\\d]" if w.nil? or w.empty?

          if /(\d+\.\d+)/ =~ b.to_s.sub(/\.0+$/, "")
            if r.nil? or r.empty?
              r = 0.1
            else
              r = (r.to_f / 10) if r.to_f >= 1
            end
            r = r.to_f
          else
            if r.nil? or r.empty?
              r = 1
            else
              r = 1 if r.to_f <= 0
            end
            a = a.to_i
            b = b.to_i
            r = r.to_i
          end

          tint = (b.to_f - a.to_f).to_i / r.to_i
          break if tint > 1000

          case (b.to_f - a.to_f).to_f
          when 0
            c = "#{w.to_s + a.to_s + z.to_s}"
          when 1
            c = "#{w.to_s + a.to_s + z.to_s}|#{w.to_s + b.to_s + z.to_s}"
          else
            if r >= 1
              c = w.to_s + a.to_s + z.to_s + "|"
              ((b - a) / r).times do |i|
                c << w.to_s + (a + ((i+1) * r)).to_s + z.to_s + "|"
              end
            else
              c = w.to_s + a.to_s.sub(/\./, "\\.") + z.to_s + "|"
              ((((b.to_f - a.to_f).to_f * 10).to_f / (r.to_f * 10)).to_i).to_i.times do |i|
                if i == 0
                  i = 1 * r.to_f
                else
                  i = (1 + i.to_f) * r.to_f 
                end
                c << w.to_s + ((a + i).round(1)).to_s.sub(/\./, "\\.") + z.to_s + "|"
              end
            end
            c = c.sub(/\|$/, "")
          end
          res << "(?=.*(#{c}))" 
        end
      end
    end
    return res
  end

  def num_search_delete(word)
    return word.dup.gsub(/(\S*)\[(\d+\.*\d*)-(\d+\.*\d*),*(\d*)\](\S*)/, "")
  end

  def search_word_save(server, word)
    words = CGI.unescape(word).toutf8
    p "Server: #{server}"
    p "SearchWord: " + words

    ckey = "search_word_days:"+server
    days = Date.parse(DateTime.now.to_s).to_s.gsub(/-/, "/")
    wordp = words.gsub(/((\\ +)|(　+))+/, " ").split(/\s+/)

    wordp.each_with_index do |word, index|
      count = 0
      count_new = 0

      pDB = PapamiraSearchWordDays.where(server: server, days: days, name: word).limit(1)
      if not pDB.empty?
        count = pDB.last[:count].to_i
        count_new = count + 1
        PapamiraSearchWordDays.where(
          server: server,
          days: days,
          name: word,
          count: count.to_s,
        ).update(count: count_new)
      else
        count = 1
        count_new = 0
        PapamiraSearchWordDays.create(
          server: server,
          days: days,
          name: word,
          count: count.to_s,
        )
      end

      if count_new > count
        feach_data = {"word" => word, "count" => count.to_s, "days" => days}
        $redis.llen(ckey).times do ||
          data = JSON.parse($redis.lpop(ckey))
          if feach_data.to_s == data.to_s
            wc = {"word" => word, "count" => count_new.to_s, "days" => days}
          else
            wc = data
          end
          $redis.rpush(ckey, JSON.generate(wc))
        end
      else
        wc = {"word" => word, "count" => count.to_s, "days" => days}
        $redis.lpush(ckey, JSON.generate(wc))
      end
    end
    $redis.expire(ckey, 86400)

    true
  end

  def server_active
    key = 'top_server_active'
    s = {
      's' => nil,
      'v' => nil,
      'b' => nil,
      'g' => nil,
      'all' => 0,
    }

    SERVERS.each do |server|
      pkey = key+":"+server

      if $redis.exists(pkey) == 0
        pDB = PapamiraShout.select(:date).where(server: server).limit(1)
        if not pDB.nil?
          pDB.order(id: :desc).each do |dbs|
            update = dbs[:date].to_s + " +0900"
            diff_time = DateTime.now.to_i - DateTime.parse(update).to_i

            if diff_time <= 3600
              s[server] = "up"
              s['all']+=1
            else
              s[server] = "down"
            end
          end
        else
          s[server] = "down"
        end
        $redis.set(pkey, s[server])
        $redis.expire(pkey, 3600)
      else
        s[server] = $redis.get(pkey)
      end
    end

    if $redis.exists(key+":all") == 0
      $redis.set(key+":all", s['all'])
      $redis.expire(key+":all", 3600)
    else
      s['all'] = $redis.get(key+":all").to_i
    end

    return JSON.generate(s)
  end

  def ranking
    body = {}
    ['s', 'b', 'v', 'g'].each do |s|
      key = "ranking:"+s

      if /^(s|b|v|g)$/ =~ s
        rank = []

        if $redis.exists(key+":name") == 0 and $redis.exists(key+":count") == 0
          tDB = {}
          limit = 5000
          days = Date.parse(DateTime.now.to_s)
          min_days = (days - 7).to_s.gsub(/-/, "/")
          max_days = days.to_s.gsub(/-/, "/")

          pDB = PapamiraShout.select(:name).where(server: s, days: min_days..max_days).limit(limit)
          pDB.order(days: :desc).each do |dbs|
            tDB[dbs['name']] = tDB[dbs['name']] ? tDB[dbs['name']] + 1 : 1
          end

          _rank = []
          tDB.each do |data|
            name = data[0]
            i = data[1]
            if i.to_i >= 10
              _rank << {"name" => name, "count" => i}
            end
          end

          n = []
          c = []

          sr = _rank.sort_by { |a| a['count'] }.reverse
          sr.each do |nc|
            n.push(nc['name'].to_s)
            c.push(nc['count'].to_s)
          end

          key_n = key + ":name"
          key_c = key + ":count"

          if !c.empty? and !n.empty?
            $redis.rpush(key_n, n)
            $redis.rpush(key_c, c)
          else
            $redis.rpush(key_n, "")
            $redis.rpush(key_c, "")
          end
          $redis.expire(key_n, 1800)
          $redis.expire(key_c, 1800)

          n.each_with_index do |n2, i2|
            rank << {"name" => n2, "count" => c[i2]} 
          end

        else
          key_n = key + ":name"
          key_c = key + ":count"

          n = $redis.LRANGE(key_n, 0, 999999)
          c = $redis.LRANGE(key_c, 0, 999999)

          n.each_with_index do |n2, i2|
            rank << {"name" => n2, "count" => c[i2]} 
          end
        end
        body[s] = rank
      end
    end

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    return JSON.generate(body)
  end

  def words
    ref = {}
    min_days = (Date.parse(DateTime.now.to_s) - 7).to_s.gsub(/-/, "/")
    max_days = Date.parse(DateTime.now.to_s).to_s.gsub(/-/, "/")

    ['all', 's', 'b', 'v', 'g'].each do |s|
      ref[s] = []
      ckey = "search_word_days:" + s

      if $redis.exists(ckey) == 0
        if PapamiraSearchWordDays.where(server: s, days: min_days..max_days).size != 0
          pDB = PapamiraSearchWordDays.where(server: s, days: min_days..max_days)
          pDB.order(days: :desc, id: :desc).each do |dbs|
            wc = {"word" => dbs[:name], "count" => dbs[:count], "days" => dbs[:days]}
            ref[s].push(wc)
            $redis.rpush(ckey, JSON.generate(wc))
          end
        end
        $redis.expire(ckey, 86400)
      else
        $redis.lrange(ckey, 0, 9999).each do |res|
          ref[s].push(JSON.parse(res))
        end
      end
    end

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    return JSON.generate(ref)
  end

  def get_itemdrops
    if PapamiraItemdrop.count == 0
      return JSON.generate([])
    else
      ref = []
      pDB = PapamiraItemdrop.all
      pDB.each do |items|
        JSON.parse(items[:data]).each do |j|
          j['uuid'] = nil
          j.delete('uuid')
          ref.push(j)
        end
      end
      return JSON.generate(ref)
    end
  end

  def get_cloudshop(params)
    uuid = CGI.escapeHTML(params[:uuid].to_s)
    if /\w{8}-\w{4}-\w{4}-\w{4}-\w{12}/ !~ uuid
      uuid = ""
    end
    uurl = {}

    unless uuid.empty?
      # DB to 
      days = Date.parse(DateTime.now.to_s)
      min_days = days - 7
      if PapamiraYourshop.where(date: min_days.to_s..days.to_s).count == 0
        randam_url = SecureRandom.hex(32).to_s
        uurl['stat'] = "200"
        uurl['uurl'] = "https://papamira.onrender.com/your_shop/" + randam_url
        params[:uurl] = randam_url
        params[:uuid] = uuid
        params[:data] = ""
        shop_data = JSON.generate([params])
        pDB = PapamiraYourshop.new(
          :date => days.to_s,
          :data => shop_data,
        )
        pDB.save
      else
        update_flg = false
        shop_data_out = nil
        data = []

        uurl['uurl'] = ""
        pDB = PapamiraYourshop.where(date: min_days.to_s..days.to_s)
        pDB.each do |ppDB|
          shop_data_in = JSON.parse(ppDB[:data])
          shop_data_in.each do |d|
            if d['data'].empty?
              if params['uuid'] == d['uuid']
                uurl['uurl'] = d['uurl']
                update_flg = true
                break
              end
            end
          end
        end

        if update_flg
          uurl['uurl'] = "https://papamira.onrender.com/your_shop/" + uurl['uurl']
          uurl['stat'] = "301"
        else
          randam_url  = SecureRandom.hex(32).to_s
          uurl['uurl'] = "https://papamira.onrender.com/your_shop/" + randam_url
          uurl['stat'] = "200"

          params[:uuid] = uuid
          params[:uurl] = randam_url
          params[:data] = ""
          shop_data = JSON.generate([params])

          pDB.update(
            :date => days.to_s,
            :data => shop_data,
          )
          pDB.save

        end
      end
      return JSON.generate(uurl)
    else
      uurl['uurl'] = ""
      uurl['stat'] = "500"
      return JSON.generate(uurl)
    end
  end

  def get_cloudshop_report(uurl, uniq_pass)
    uurl = CGI.escapeHTML(uurl.to_s)
    uniq_pass = CGI.escapeHTML(uniq_pass.to_s)

    body = []
    if uniq_pass.size == 32
      days = Date.parse(DateTime.now.to_s)
      min_days = days - 7
      if PapamiraYourshop.where(date: min_days.to_s..days.to_s).count != 0
        uuid = ''
        pDB = PapamiraYourshop.where(date: min_days.to_s..days.to_s)
        pDB.each do |ppDB|
          data = JSON.parse(ppDB[:data])
          data.each do |d|
            if d['uurl'] == uurl
              unless d['data'].nil?
                if d['data'].empty?
                  uuid = d['uuid']
                end
              end
            end
          end

          unless uuid.empty?
            data.each do |d|
              if d['uuid'] == uuid
                unless d['data'].nil?
                  unless d['data'].empty?
                    begin
                      aes_data = Base64::decode64(d['data'])
                      dec = OpenSSL::Cipher.new('AES-256-CBC')
                      dec.decrypt
                      salt = aes_data[8,8]
                      aes_data_nonsalt = aes_data[16, aes_data.size]
                      dec.pkcs5_keyivgen(uniq_pass, salt)

                      begin
                        dtext =  dec.update(aes_data_nonsalt).force_encoding("UTF-8")
                        dtext << dec.final.force_encoding("UTF-8")
                      rescue
                        iv = 'i' * 16
                        dec.key = uniq_pass
                        dec.iv = iv
                        dtext =  dec.update(aes_data).force_encoding("UTF-8")
                        dtext << dec.final.force_encoding("UTF-8")
                      end
                      if /で販売$/ =~ dtext
                        if /目のアイテムを/ =~ dtext
                          body.push(dtext)
                        end
                      end
                    rescue ArgumentError => e
                      body.push(e.to_s)
                    rescue => e
                      body.push(e.to_s)
                    end
                  end
                end
              end
            end
          end
        end
      end
    end
    return body.sort.join("<br>\n")
  end
  
  def now_shout
    body = ""
    key = 'top_now_shout'

    if $redis.exists(key) == 0
      shout_max = PapamiraShout.maximum(:id)
      pDB = PapamiraShout.where(id: shout_max).first
      body << pDB['body'] if !pDB.nil?
      $redis.set(key, body)
      $redis.expire(key, 1800)
    else
      body = $redis.get(key)
    end

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    return JSON.generate(body)
  end

  def random_shout
    pDB = []
    shout_max = PapamiraShout.maximum(:id)
    loop {
      pDB = PapamiraShout.where(id: rand(1..shout_max))
      break if not pDB.empty?
    }
    body = pDB[:body]
    JSON.generate(body)
  end

  def shout(params)
    server = CGI.escapeHTML(params[:server].to_s)
    tDB = []

    if /^(s|b|v|g)$/ =~ server
      index = 0
      limit = 100
      ckey = "shout_" + server

      if $redis.exists(ckey) == 0

        min_days = (Date.parse(DateTime.now.strftime("%Y/%m/%d")) - 1).to_s.gsub(/-/, "/")
        max_days = DateTime.now.strftime("%Y/%m/%d")

        pDB = PapamiraShout.where(server: server, days: min_days..max_days)
        pDB.order(date: :desc).limit(limit).each do |dbs|
          if PRIVACY_LEVEL >= 1
            if (DateTime.now.to_i - DateTime.parse(dbs.date).to_i).to_i > (86400 * 2)
              dbs.date = dbs.date.split(/ /)[0]
            end
          end
          tDB.push(dbs.attributes)
        end

        tDB.each do |tDB2|
          $redis.rpush(ckey, JSON.generate(tDB2))
        end
        $redis.expire(ckey, 6000)
      else
        $redis.lrange(ckey, 0, 999999).each do |tDB2|
          tDB.push(JSON.parse(tDB2))
        end
      end
    end

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    JSON.generate(tDB)
  end

  def shout_days(params)
    tDB = []
    server = CGI.escapeHTML(params[:server].to_s)

    if /^(s|b|v|g)$/ =~ server
      limit = params['limit'].to_i
      if /\d+/ =~ limit.to_s
        if limit > 30
          limit = 30
        elsif limit <= 0
          limit = 1
        end
      else
        limit = 1
      end

      ckey = "shout_days_" + server + "_" + limit.to_s

      if limit != 0
        min_days = (Date.parse(DateTime.now.strftime("%Y/%m/%d")) - limit).to_s.gsub(/-/, "/")
        max_days = DateTime.now.strftime("%Y/%m/%d")
      else
        min_days = DateTime.now.strftime("%Y/%m/%d")
        max_days = DateTime.now.strftime("%Y/%m/%d")
      end

      pDB = PapamiraShout.where(server: server, days: min_days..max_days)
      pDB.order(date: :desc).each do |dbs|
        if PRIVACY_LEVEL >= 1
          if (DateTime.now.to_i - DateTime.parse(dbs.date).to_i).to_i > (86400 * 2)
            dbs.date = dbs.date.split(/ /)[0]
          end
        end
        tDB.push(dbs.attributes)
      end
    end

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    return JSON.generate(tDB)
  end

  def history_shout(params)
    tDB = []
    server = CGI.escapeHTML(params[:server].to_s)
    limit = 50
    ckey = "history_shout_" + server

    if $redis.exists(ckey) == 0
      if /^(s|b|v|g)$/ =~ server
        pDB = PapamiraShout
        pDB.where(server: server).order(date: :desc).limit(limit).each do |dbs|
          if PRIVACY_LEVEL >= 1
            if (DateTime.now.to_i - DateTime.parse(dbs.date).to_i).to_i > (86400 * 2)
              dbs.date = dbs.date.split(/ /)[0]
            end
          end
          tDB.push(dbs.attributes)
          $redis.rpush(ckey, JSON.generate(dbs.attributes))
        end
        $redis.expire(ckey, 3600)
      end
    else
      $redis.lrange(ckey, 0, 50).each do |_res|
        tDB.push(JSON.parse(_res))
      end
    end

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    return JSON.generate(tDB)
  end

  def all_shout
    tDB = []

    limit = 30
    range = 4

    ckey = "all_shout"

    if $redis.exists(ckey) == 0

      pDB = PapamiraShout
      pDB.order(date: :desc).limit(limit*range).each do |dbs|
        if PRIVACY_LEVEL >= 1
          if (DateTime.now.to_i - DateTime.parse(dbs.date).to_i).to_i > (86400 * 2)
            dbs.date = dbs.date.split(/ /)[0]
          end
        end

        tDB.push(dbs.attributes)
      end

      tDB.each do |tDB2|
        $redis.rpush(ckey, JSON.generate(tDB2))
      end
      $redis.expire(ckey, 6000)
    else
      $redis.lrange(ckey, 0, 999999).each do |tDB2|
        tDB.push(JSON.parse(tDB2))
      end
    end

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    return JSON.generate(tDB)
  end

  def top_shout
    tDB = []

    limit = 5
    range = 1

    ckey = "top_shout"

    if $redis.exists(ckey) == 0
      pDB = PapamiraShout
      pDB.order(date: :desc).limit(limit*range).each do |dbs|
        if PRIVACY_LEVEL >= 1
          if (DateTime.now.to_i - DateTime.parse(dbs.date).to_i).to_i > (86400 * 2)
            dbs.date = dbs.date.split(/ /)[0]
          end
        end

        tDB.push(dbs.attributes)
      end

      tDB.each do |tDB2|
        $redis.rpush(ckey, JSON.generate(tDB2))
      end
      $redis.expire(ckey, 6000)
    else
      $redis.lrange(ckey, 0, 999999).each do |tDB2|
        tDB.push(JSON.parse(tDB2))
      end
    end

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    return JSON.generate(tDB)
  end

  def select_history_words(params)
    day = CGI.escapeHTML(params[:day].to_s)
    ymd = day.scan(%r!^(\d{4})[/|-](\d{2})[/|-](\d{2})$!).join("/")
    ref = {}

    ['all','s', 'b', 'v', 'g'].each do |s|
      ref[s] = []
      if (not ymd.nil?)
        if %r!^(\d{4})/(\d{2})/(\d{2})$! =~ ymd
          ckey = "select_hisotry_words:" + s + ":" + ymd

          if $redis.exists(ckey) == 0
            pDB = PapamiraSearchWordDays.where(server: s, days: ymd)
            pDB.order(days: :desc).each do |dbs|
              wc = {"word" => dbs[:name], "count" => dbs[:count], "days" => dbs[:days]}
              ref[s].push(wc)
              $redis.rpush(ckey, JSON.generate(wc))
            end
            $redis.expire(ckey, 3600)
          else
            $redis.lrange(ckey, 0, 9999).each do |res|
              ref[s].push(JSON.parse(res))
            end
          end
        end
      end
    end

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    return JSON.generate(ref)
  end

  def select_day(params, uniq_id="")
    day = CGI.escapeHTML(params[:day].to_s)
    server = CGI.escapeHTML(params[:server].to_s)

    ymd = day.scan(%r!^(\d{4})[/|-](\d{2})[/|-](\d{2})$!).join("/")
    body = []

    if (not ymd.nil?)
      if %r!^(\d{4})/(\d{2})/(\d{2})$! =~ ymd
        if not day.nil?
          ckey = "day_" + server + "_" + ymd
          pDB = PapamiraShout.where(server: server, days: ymd)
          pDB.order(date: :desc).each do |dbs|
            if PRIVACY_LEVEL >= 1
              timer = (DateTime.now.to_i - DateTime.parse(dbs.date).to_i).to_i
              if PRIVACY_LEVEL >= 2
                if timer > (86400 * 30)
                  dbs.body = dbs.body[0..4] + "..."
                end
              end
              if timer > (86400 * 14)
                dbs.name = "ぱぱみら"
              end
              if timer > (86400 * 2)
                dbs.date = dbs.date.split(/ /)[0]
              end
            end
            body.push(dbs.attributes)
          end
        end

        ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
        GC.start
      end
    end

    JSON.generate(body)
  end

  def select_shout_for_id(params)
    id = CGI.escapeHTML(params[:id].to_s)
    pDB = PapamiraShout.select(:server, :name).find_by(id: id)
    name = pDB.name
    server = pDB.server
    body = []

    pDB2 = PapamiraShout.select(:server, :name, :date, :body).where("name &@ ? and server = ?", name, server)
    pDB2.order(date: :desc).each do |dbs|
      body.push(dbs.attributes)
    end

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    JSON.generate(body)
  end

  def select_shout(params)
    day = CGI.escapeHTML(params[:day].to_s)
    server = CGI.escapeHTML(params[:server].to_s)

    y, m, d, page = day.scan(%r!^(\d{4})[/|-](\d{2})[/|-](\d{2})[/|-](([0-9]|-|,)+)$!).flatten
    ymd = [y, m, d].join("/")
    body = []

    if (not ymd.nil?)
      if %r!^(\d{4})/(\d{2})/(\d{2})$! =~ ymd
        if not day.nil? and not page.nil?

          ckey = "day_" + server + "_" + ymd + "_" + page.to_s
          pages = []

          if /,/ =~ page.to_s
            page.split(/,/).each do |tp|
              if /-/ =~ tp
                pages.push(tp.split(/-/))
              else
                pages.push(tp)
              end
            end
          else
            if /-/ =~ page.to_s
              pages.push(page.split(/-/))
            else
              pages.push(page)
            end
          end

          pages.each do |offset|
            if offset.class == Array
              limit = (offset[1].to_i - offset[0].to_i)
              limit = (offset[0].to_i - offset[1].to_i) if limit <= 0
              limit = 1 if limit <= 0

              pDB = PapamiraShout.where(server: server, days: ymd)
              pDB.order(date: :asc).limit(limit).offset(offset[0]).each do |dbs|
                if PRIVACY_LEVEL >= 1
                  timer = (DateTime.now.to_i - DateTime.parse(dbs.date).to_i).to_i
                  if PRIVACY_LEVEL >= 2
                    if timer > (86400 * 30)
                      dbs.body = dbs.body[0..4] + "..."
                    end
                  end
                  if timer > (86400 * 14)
                    dbs.name = "ぱぱみら"
                  end
                  if timer > (86400 * 2)
                    dbs.date = dbs.date.split(/ /)[0]
                  end
                end
                body.push(dbs.attributes)
              end
            else
              pDB = PapamiraShout.where(server: server, days: ymd)
              pDB.order(date: :asc).limit(1).offset(offset).each do |dbs|
                if PRIVACY_LEVEL >= 1
                  timer = (DateTime.now.to_i - DateTime.parse(dbs.date).to_i).to_i
                  if PRIVACY_LEVEL >= 2
                    if timer > (86400 * 30)
                      dbs.body = dbs.body[0..4] + "..."
                    end
                  end
                  if timer > (86400 * 14)
                    dbs.name = "ぱぱみら"
                  end
                  if timer > (86400 * 2)
                    dbs.date = dbs.date.split(/ /)[0]
                  end
                end
                body.push(dbs.attributes)
              end
            end
          end
        end
      end
    end

    JSON.generate(body)
  end

  def autocomplete(params)
    data = params['req']
    key = "autocomplete_data"
    res = []

    if not data.nil?
      if $redis.exists(key) == 0
        items = File.open("data/item.dat").read.split(/\n/)
        items.each do |item|
          res.push(item) if /^#{data}/ =~ item
          $redis.rpush(key, item)
        end
        $redis.expire(key, 3600*24)

        #PapamiraItem.where("name like '%" + data + "%'").each do |text|
        #  res.push(text[:name]) if /^#{data}/ =~ text[:name]
        #end

        #PapamiraUserWord.where("name like '%" + data + "%'").each do |text|
        #  res.push(text[:name]) if /^#{data}/ =~ text[:name]
        #end
      else
        items = $redis.LRANGE(key, 0, 999999)
        items.each do |item|
          res.push(item) if /^#{data}/ =~ item
        end
      end
      GC.start
    end

    JSON.generate(res.uniq)
  end

  def user_search_word(params)
    sv = [params['server']]
    sv = ['s','b','v','g'] if sv.first == 'all'

    ref = {}

    res_sv = ""
    sv.each do |s|
      res_sv = s
      ckey = "search_word_days:" + s

      ref[s] = []
      if $redis.exists(ckey) != 0
        $redis.lrange(ckey, -0, 9).each do |res|
          data = JSON.parse(res)
          ref[s].push(data)
        end
        user_word = []
        ref[s].sort_by! { |a| a['days'] }.reverse_each do |data|
          user_word.push(data['word'])
        end
        ref[s] = user_word.uniq
      end
    end

    if ref.size == 1
      return JSON.generate(ref[res_sv])
    else
      all_ref = []
      ref.each do |s, val|
        all_ref.push(val)
      end
      return JSON.generate(all_ref.flatten.uniq)
    end
  end

  def old_user_search_word(params)
    server = params['server']
    user_word = []
    if PapamiraSearchWord.where(server: server).size != 0
      pDB = PapamiraSearchWord.find_by(server: server)
      body_in = JSON.parse(pDB[:data])
      body_in.sort_by! { |a| a['count'] }.reverse_each do |data|
        if data['count'].to_i >= 20
          user_word.push(data['body'])
        end
      end
    else
      user_word = []
    end
    return JSON.generate(user_word)
  end

  def search_shout_v2(params)
    server = params[:server]
    query = params[:word]

    if params[:number].nil?
      number = 100
    else
      if /\d+/ =~ params[:number]
        if params[:number].to_i < 0
          number = 0
        else
          number = params[:number].to_i
        end
        range = 1000 if params[:number].to_i > 1000
      else
        number = 100
      end
    end

    if params[:range].nil?
      range = 30
    else
      if /\d+/ =~ params[:range]
        if params[:range].to_i < 0
          range = 30
        else
          range = params[:range].to_i
        end
        range = 30 if params[:range].to_i > 30
      else
        range = 30
      end
    end

    res = []
    if query.present? and server.present? and /^(s|b|v|g|all)$/ =~ server
      if lock(server)
        res << render_popup
      else
        keywords_org = PapamiraShout.sanitize_sql_like(NKF.nkf("-Xwm0Z1", query.upcase).to_s)
        keywords_enc = Base64::encode64(keywords_org)
        keywords = keywords_org.split(/\s+/)

        if keywords.present?
          ckey = server +":"+ keywords_enc.sub(/==\n$/, "") + number.to_s + range.to_s

          $search_stack[server] += 1
          if $search_stack[server] > $search_max[server]
            res = [{
              'server' => server,
              'stat' => "err",
              'name' => 'ぱぱみら',
              'body' => self.render_wait_search,
              'date' => "error",
              'days' => "none"}]
          else
            if $redis.exists(ckey) == 0
              if server == 'all'
                pDB = PapamiraShout.where.not(server: "g")
              else
                pDB = PapamiraShout.where(server: server)
              end

              keywords.each do |keyword|
                if /^!/ =~ keyword
                  keyword = keyword.sub(/^!/, "")
                  pDB = pDB.where("body not like :q and name not like :q", q: "%#{keyword}%")
                else
                  pDB = pDB.where("body like :q or name like :q", q: "%#{keyword}%")
                end
                $redis.rpush("worker_spool", JSON.generate({'namespace' => "search_word_save", 'server' => server, 'word' => keyword }))
              end
              pDB.order(id: :desc).limit(number).each do |dbs|
                ref = dbs.attributes
                $redis.rpush(ckey, JSON.generate(ref))
                res.push(ref)
              end
              $redis.expire(ckey, 60)
            else
              $redis.lrange(ckey, 0, 9999).each do |ref|
                res.push(JSON.parse(ref))
              end
            end

            ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
            GC.start
          end
          $search_stack[server] -= 1
          res.sort_by! { |a| a['date'] }.reverse!
        else
          res = []
        end
      end
    end

    JSON.generate(res)
  end

  def search_shout(params)
    self.search_shout_v2(params)
  end

  def search_tags(params)
    server = params[:s].to_s
    res = []
    if lock(server)
      res << render_popup
    else
      key = Regexp.escape(CGI.escapeHTML(params[:tag].toutf8)).to_s
      case key
      when "買"
        key = ["買", "露店"]
        key2 = "(買|露店)"
      when "売"
        key = ["売", "露店"]
        key2 = "(売|露店)"
      when "ギルド"
        key = ["ギルド", "攻城", "ステG", "GVG"]
        key2 = "(?=.*(ギルド|攻城|ステG|GVG))^(?!.*(ギルドクエ|ギルドデイリ)).*$"
      when "秘密"
        key = ["秘密", "PT"]
        key2 = "(秘密|PT)"
      when "PT"
        key = ["", "PT", "ハント"]
        key2 = "(?=.*(PT))^(?!.*(PTハンティング|Gクエ)).*$"
      when "かけら"
        key = ["かけら", "欠片", "カケラ", "飛ばし", "代行", "出し"]
        key2 = "(?=.*(かけら|欠片|カケラ))(?=.*(飛ばし|代行|出し))^(?!.*(黒き炎|魔界|試練|神秘)).*$"
      when "各種代行"
        key = ["代行"]
        key2 = "(?=.*代行)^(?!.*(欠片|かけら|カケラ)).*$"
      when "GEM"
        key = ["GEM"]
        key2 = "GEM"
      when "クエ"
        key = ["メインクエ", "MQ"]
        key2 = "(?=.*(メインクエ|MQ))"
      when "鏡"
        key = ["鏡"]
        key2 = "(?=.*(鏡))^(?!.*(神秘|魔界)).*$"
      when "テイム"
        key = ["テイム"]
        key2 = "テイム"
      when "ツボ"
        key = ["壷"]
        key2 = "(壷|つぼ|ツボ)"
      when "インク"
        key = ["インク"]
        key2 = "(?=.*(インク))^(?!.*(メインクエ)).*$"
      when "クレスト"
        key = ["クレスト"]
        key2 = "(?=.*(クレスト))"
      when "その他"
        key = ["その他"]
        key2 = "^(?!.*(よろ|締め切り|インク|露店|＠|ラット|エンチャ|出|古代王|代行|G|BF|リスト|発|レイド|待機|放置|〆|買|売|求|鏡|秘密|募集|神秘|魔界|MQ|GEM|欠片|かけら|カケラ|黒き炎|魔界|試練|神秘|PT|ハンティング|ギルド|クエ|デイリ)).*$"
      else
        key = []
        key2 = ""
      end

      if not key2.empty?
        ckey = server + key.join
        $search_stack[server] += 1
        if $search_stack[server] > $search_max[server]
          res << render_wait_search
        else
          case server
          when 'all'
            sql = ""
          when 's', 'b', 'v', 'g'
            sql = "server = \'#{server}\' and ("
          else
            sql = ""
          end

          key.each do |k|
            sql += "(body like '%#{k}%' or name like '%#{k}%') or "
          end
          sql_sec = sql.sub(/ or $/, ")")

          pDB = PapamiraShout.where(sql_sec).limit(300)
          pDB.order(date: :desc).each do |dbs|
            res << dbs.attributes
          end
        end

        $search_stack[server] -= 1
      end

      ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
      GC.start

    end

    JSON.generate(res)
  end

  def time_of_days(server, limit)
    server ='all' if server.nil?
    limit = 1 if limit.nil?
    if /^\d+$/ =~ limit.to_s
      limit = limit.to_i
    else
      limit = 1
    end

    if not server.nil? and not limit.nil?

      if limit != 0
        min_days = (DateTime.now - limit).strftime("%Y/%m/%d")
        max_days = DateTime.now.strftime("%Y/%m/%d")
      else
        min_days = DateTime.now.strftime("%Y/%m/%d")
        max_days = DateTime.now.strftime("%Y/%m/%d")
      end

      if server.empty? or server == 'all'
        tDB = {
          's' => [],
          'b' => [],
          'v' => [],
          'g' => [],
        }

        SERVERS.each do |s|
          pDB = PapamiraShout.select(:server, :date).where(server: s, days: min_days..max_days)
          pDB.order(days: :desc).each do |dbs|
            tDB[dbs[:server]].unshift({'date' => dbs[:date]})
          end
        end
      else
        tDB = []
        pDB = PapamiraShout.select(:server, :date).where(server: server, days: min_days..max_days)
        pDB.order(days: :desc).each do |dbs|
          tDB.unshift(dbs.attributes)
        end
      end

      return tDB
    else
      return []
    end
  end

  def graph_select_day(params)
    days = params[:days]

    key = "info:"+"#{days}:"+"days"

    res = {
      's' => [],
      'b' => [],
      'v' => [],
      'g' => [],
    }

    if not days.nil?
      if $redis.exists(key) == 0

        ymd = days.gsub(/-/, "/")

        if %r!^(\d{4})/(\d{2})/(\d{2})$! =~ ymd
          pDB = PapamiraShout.select(:server, :date).where(days: ymd)
          pDB.each do |dbs|
            res[dbs[:server]].push(dbs[:date])
          end
        end

        $redis.set(key, "cache")
        $redis.rpush(key+":s", res['s']) if !res['s'].empty?
        $redis.rpush(key+":b", res['b']) if !res['b'].empty?
        $redis.rpush(key+":v", res['v']) if !res['v'].empty?
        $redis.rpush(key+":g", res['g']) if !res['g'].empty?

        $redis.expire(key, 300)
        $redis.expire(key+":s", 300)
        $redis.expire(key+":b", 300)
        $redis.expire(key+":v", 300)
        $redis.expire(key+":g", 300)
      else
        res['s'] = $redis.LRANGE(key+":s", 0, 999999)
        res['b'] = $redis.LRANGE(key+":b", 0, 999999)
        res['v'] = $redis.LRANGE(key+":v", 0, 999999)
        res['g'] = $redis.LRANGE(key+":g", 0, 999999)
      end
    end

    date_now = ""
    date_last = ""
    date_feach = ""

    title_server = "3"
    range = days.to_s

    active_hash = {}
    SERVERS.each do |s|
      active_hash[s] = {}
      24.times do |t|
        active_hash[s][t] = 0
      end
    end

    res.each do |s, data|
      data.each do |date|

        date_now = Date.parse(date)
        if date_last == ""
          date_last = date_now.dup
          date_feach = date_now - days.to_i
        end

        break if date_now < date_feach

        hh = ParseDate::parsedate(date)[3]
        active_hash[s][hh.to_i] += 1
      end
    end

    body = graph_js(active_hash, "時", 'day')

    res = {
      "body" => body,
      "server" => title_server,
      "range" => range,
    }

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    JSON.generate(res)
  end

  def graph_server(params)
    s = params[:server].to_s
    title_server = s.upcase

    key = "info:"+"#{s}:"+"alldays"+":v2"

    active_hash = {}
    24.times do |t|
      active_hash[t] = 0
    end

    ldate = ""
    fdate = ""
    if $redis.exists(key) == 0
      self.time_of_days(s, 90).each do |text|
        date = text['date']
        if ldate.empty?
          ldate = date
          fdate = date
        else
          if ldate > date
            ldate = date
          end
          if fdate < date
            fdate = date
          end
        end

        hh = ParseDate::parsedate(date)[3]
        active_hash[hh] += 1
      end

      date_area = ldate.split(/ /)[0].to_s + "-" + fdate.split(/ /)[0].to_s
      if date_area != '-'
        range = "[#{date_area}]"
      else
        range = ""
      end

      $redis.set(key+":range", range)
      $redis.hset(key, active_hash)
      $redis.expire(key, 300)
    else
      active_hash = $redis.hgetall(key)
      range = $redis.get(key+":range")
    end

    active_hash_v2 = {
      "data" => active_hash,
      "range" => range,
    }

    body = graph_js(active_hash, "時", 'server')

    res = {
      "body" => body,
      "server" => title_server,
      "range" => range,
    }

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    JSON.generate(res)
  end

  def graph_days(params)
    days = params[:day]
    days = "1" if days.nil?
    days = "1" if days.empty?
    days = "1" if /^\d+$/ !~ days.to_s
    days = "30" if days.to_i > 30
    days = days.to_i

    date_now = ""
    date_last = ""
    date_feach = ""

    title_server = "3"
    range = days.to_s

    key = "all:"+(days+1).to_s+":"+"days"

    active_hash = {
      's' => {},
      'b' => {},
      'v' => {}, 
      'g' => {}, 
    }
    24.times do |t|
      active_hash['s'][t] = 0
      active_hash['b'][t] = 0
      active_hash['v'][t] = 0
      active_hash['g'][t] = 0
    end

    if $redis.exists(key) == 0
      self.time_of_days("all", days+1).each do |sname, data|
        data.each do |text|
          date = text['date']

          date_now = Date.parse(date)
          if date_last == ""
            date_last = date_now.dup
            date_feach = date_now - days.to_i
          end

          break if date_now < date_feach

          hh = ParseDate::parsedate(date)[3]
          active_hash[sname][hh.to_i] += 1
        end
      end

      $redis.set(key, "cache")
      $redis.hset(key+":s", active_hash['s'])
      $redis.hset(key+":b", active_hash['b'])
      $redis.hset(key+":v", active_hash['v'])
      $redis.hset(key+":g", active_hash['g'])

      $redis.expire(key, 300)
      $redis.expire(key+":s", 300)
      $redis.expire(key+":b", 300)
      $redis.expire(key+":v", 300)
      $redis.expire(key+":g", 300)
    else
      active_hash['s'] = $redis.hgetall(key+":s")
      active_hash['b'] = $redis.hgetall(key+":b")
      active_hash['v'] = $redis.hgetall(key+":v")
      active_hash['g'] = $redis.hgetall(key+":g")
    end

    body = graph_js(active_hash, "時", 'day')

    res = {
      "body" => body,
      "server" => title_server,
      "range" => range,
    }

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    JSON.generate(res)
  end

  def graph_wdays(params)
    days = params[:day]
    days = "7" if days.nil?
    days = "7" if days.empty?
    days = "7" if /^\d+$/ !~ days.to_s
    days = "28" if days.to_i > 28
    days = days.to_i
    date_now = ""
    date_last = ""
    date_feach = ""

    title_server = "3"
    range = days.to_s

    key = "all:"+days.to_s+":"+"days"

    active_hash = {
      's' => {},
      'b' => {},
      'v' => {}, 
      'g' => {}, 
    }
    7.times do |t|
      active_hash['s'][t] = 0
      active_hash['b'][t] = 0
      active_hash['v'][t] = 0
      active_hash['g'][t] = 0
    end

    if $redis.exists(key) == 0
      self.time_of_days("all", days).each do |sname, data|
        data.each do |text|
          date = text['date']

          date_now = Date.parse(date)
          if date_last == ""
            date_last = date_now.dup
            date_feach = date_now - days.to_i
          end

          break if date_now < date_feach

          hh = ParseDate::parsedate(date)[3]
          this_wday = date_now.wday
          active_hash[sname][this_wday] += 1
        end
      end

      $redis.set(key, "cache")
      $redis.hset(key+":s", active_hash['s'])
      $redis.hset(key+":b", active_hash['b'])
      $redis.hset(key+":v", active_hash['v'])
      $redis.hset(key+":g", active_hash['g'])

      $redis.expire(key, 300)
      $redis.expire(key+":s", 300)
      $redis.expire(key+":b", 300)
      $redis.expire(key+":v", 300)
      $redis.expire(key+":g", 300)
    else
      active_hash['s'] = $redis.hgetall(key+":s")
      active_hash['b'] = $redis.hgetall(key+":b")
      active_hash['v'] = $redis.hgetall(key+":v")
      active_hash['g'] = $redis.hgetall(key+":g")
    end

    body = graph_js(active_hash, "曜日", 'wday')

    res = {
      "body" => body,
      "server" => title_server,
      "range" => range,
    }

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    JSON.generate(res)
  end

  def graph_js(active_hash, unit, type)
    case type
    when 'day'
      return graph_d_js(active_hash, unit)
    when 'server'
      return graph_s_js(active_hash, unit)
    when 'wday'
      return graph_w_js(active_hash, unit)
    end
  end

  def graph_s_js(active_hash, unit)
    all = []

    active_hash.each do |time, val|
      omoshi = graph_omoshi(time.to_i)
      all.push([time, val.to_i, omoshi])
    end

    body = []
    all.sort {|a, b| a[2] <=> b[2] }.each do |t, val, omoshi|
      body.push( { "label" => t.to_s+unit, "y" => val.to_i, } )
    end

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    return body
  end

  def graph_d_js(active_hash, unit)
    all = {
      's' => [],
      'b' => [],
      'v' => [],
      'g' => [],
    }

    active_hash.each do |name, vals|
      vals.each do |time, val|
        omoshi = graph_omoshi(time.to_i)
        all[name].push([time, val.to_i, omoshi])
      end
    end

    body = {}
    all.each do |name, vals|
      body[name] = []
      vals.sort {|a, b| a[2] <=> b[2] }.each do |t, val, omoshi|
        body[name].push( { "label" => t.to_s+unit, "y" => val.to_i, } )
      end
    end

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    return body
  end

  def graph_w_js(active_hash, unit)
    dayweek = ["日", "月", "火", "水", "木", "金", "土"]
    all = {
      's' => [],
      'b' => [],
      'v' => [],
      'g' => [],
    }

    active_hash.each do |name, vals|
      vals.each do |time, val|
        omoshi = graph_omoshi_wdays(time.to_i)
        all[name].push([time, val.to_i, omoshi])
      end
    end

    body = {}
    all.each do |name, vals|
      body[name] = []
      vals.sort {|a, b| a[2] <=> b[2] }.each do |t, val, omoshi|
        body[name].push( { "label" => dayweek[t.to_i]+unit, "y" => val.to_i, } )
      end
    end

    return body
  end

  def graph_omoshi(str)
    a = {}
    s = 18
    24.times do |i|
      s = 0 if s > 23
      a[i] = s
      s+=1
    end
    return a[str]
  end

  def graph_omoshi_wdays(str)
    a = {}
    s = 4
    7.times do |i|
      s = 0 if s > 6
      a[i] = s
      s+=1
    end
    return a[str]
  end

  def _1day_shout(params)
    res = []
    server = params['server']
    if not server.nil?
      if not server.empty? and /^(s|b|v|g)$/ =~ server
        day_last = PapamiraShout.where(server: server).maximum(:id)[:days]
        pDB = PapamiraShout.where(days: day_last)
        pDB.each do |dbs|
          body.delete('stat')
          res << dbs.attributes
        end
      else
        res = "error Server Name."
      end
    else
      res = "error Server Name no set."
    end

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    JSON.generate(res)
  end

  def all_web_connect
    return JSON.generate($web_clients.size)
  end

  def web_connect(params)
    server = params['server']
    if not server.nil?
      if not server.empty? and /^(s|b|v|g|all)$/ =~ server
        int = 0
        $web_clients.each do |w|
          if /^\/#{server}\/(stream|ppap)$/ =~ w.env["REQUEST_PATH"]
            int += 1
          end
        end
        res = int.to_s
      else
        res = "error Server Name."
      end
    else
      res = "error Server Name no set."
    end
    return JSON.generate(res)
  end

  def web_connects
    group = {}
    ['s', 'b', 'v', 'g', 'all', 'home'].each do |s|
      group[s] = 0
    end

    int = 0
    $web_clients.each do |w|
      case w.env["REQUEST_PATH"]
      when /^\/s\/(stream|ppap)$/
        group['s'] += 1
      when /^\/b\/(stream|ppap)$/
        group['b'] += 1
      when /^\/v\/(stream|ppap)$/
        group['v'] += 1
      when /^\/g\/(stream|ppap)$/
        group['g'] += 1
      when /^\/all\/(stream|ppap)$/
        group['all'] += 1
      else
        group['home'] += 1
      end
    end
    return JSON.generate(group)
  end

  def server_alive(params)
    res = ""
    server = params['server']
    if not server.nil?
      if not server.empty? and /^(s|b|v|g|all)$/ =~ server
        s = {}
        key = "server_alive:"+server

        if $redis.exists(key) == 0
          ["s", "b", "v", "g"].each do |server|
            s[server] = "down"
            if PapamiraShout.select(date:).where(server: server).size != 0
              pDB = PapamiraShout.select(date:).find_by(server: server)
              pDB.order(days: :desc).each do |dbs|
                update = dbs[:date] + " +0900"
                diff_time = DateTime.now.to_i - DateTime.parse(update).to_i
                s[server] = "up" if diff_time <= 3600
              end
            end
          end

          case server
          when 'all'
            res = s
            $redis.hset(key, res)
          else
            res = s[server]
            $redis.set(key, res)
          end
          $redis.expire(key, 900)
        else
          case server
          when 'all'
            res = $redis.hgetall(key)
          else
            res = $redis.get(key)
          end
        end
      else
        res = "error Server Name."
      end
    else
      res = "error Server Name no set."
    end

    ObjectSpace.each_object(ActiveRecord::Relation).each(&:reset)
    GC.start

    return JSON.generate(res)
  end

  def server_power
    key = 'server_power'
    power = 0

    if $redis.exists(key) == 0
      power = PapamiraShout.maximum(:id).to_i
      $redis.set(key, power)
      $redis.expire(key, 3600*24)
    else
      power = $redis.get(key)
    end
    return JSON.generate(kanma3(power))
  end

  def voice_dic
    key = "voice_dic_v1"
    res = JSON.parse(File.open("data/web_speech.dic").read)
    return JSON.generate(res)
  end

  def kanma3(v)
    return v.to_s.scan(/(\d{1,3})(?=(?:\d{3}*$))/).join(",")
  end
end
