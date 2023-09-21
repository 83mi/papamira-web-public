class Papamira_extra
  def proxy_kr(params)
    thread = []
    doc = ""
    ourl = "http://redstone.logickorea.co.kr"
    murl = "http:\/\/redstone.logickorea.co.kr"
    purl = "https://papamira.herokuapp.com/proxy_kr"
    #ourl = "http://members.redsonline.jp"
    #murl = "http:\/\/members.redsonline.jp"
    #purl = "http://localhost:4567/proxy_kr"
    
    op = ""
    params.each do |key, val|
      if op.empty?
        op << "?#{key}=#{val}"
      else
        op << "&#{key}=#{val}"
      end
    end

    if op == "?ref="
      url = ourl
    else
      url = ourl +"/"+ op.gsub(/\?ref=\//, "")
    end

    uri = Addressable::URI.parse(url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      response = http.get(uri.request_uri)
      body = response.body.toutf8
      doc = Nokogiri::HTML(body)

      (doc/'script').remove
      (doc/'comment').remove
      
      doc.css('a').each do |anchor|
        if /^http/ !~ anchor[:href] and /^javascript/ !~ anchor[:href]
          anchor[:href] = ourl +"/"+ anchor[:href].sub(/^\/+/,"")
        end
        if op == ""
          anchor[:href] = anchor[:href].gsub(/#{murl}/, purl+"?ref=")
        else
          anchor[:href] = anchor[:href].gsub(/#{murl}/, purl+"?ref=")
        end
      end
      
      doc.css('img').each do |anchor|
        t = Thread.start do
          if /^http/ =~ anchor[:src]
            url2 = anchor[:src]
          else
            url2 = ourl + anchor[:src]
          end
          uri2 = Addressable::URI.parse(url2)
          Net::HTTP.start(uri2.host, uri2.port) do |http|
            response2 = http.get(uri2.request_uri)
            body2 = response2.body
            case anchor[:src]
            when /\.gif$/
              anchor[:src] = "data:image/gif;base64,"+ Base64.encode64(body2).gsub(/\n/, "")
            when /\.png$/
              anchor[:src] = "data:image/png;base64,"+ Base64.encode64(body2).gsub(/\n/, "")
            when /\.jpg$/
              anchor[:src] = "data:image/jpeg;base64,"+ Base64.encode64(body2).gsub(/\n/, "")
            end
          end
        end
        thread.push(t)
      end

      doc.css('td').each do |anchor|
        if not anchor[:background].nil?
          t = Thread.start do
            url2 = ourl + anchor[:background]
            uri2 = Addressable::URI.parse(url2)
            Net::HTTP.start(uri2.host, uri2.port) do |http|
              response2 = http.get(uri2.request_uri)
              body2 = response2.body
              case anchor[:background]
              when /\.gif$/
                anchor[:background] = "data:image/gif;base64,"+ Base64.encode64(body2).gsub(/\n/, "")
              when /\.png$/
                anchor[:background] = "data:image/png;base64,"+ Base64.encode64(body2).gsub(/\n/, "")
              when /\.jpg$/
                anchor[:background] = "data:image/jpeg;base64,"+ Base64.encode64(body2).gsub(/\n/, "")
              end
            end
          end
          thread.push(t)
        end
      end

      thread.each do |t|
        while t.status == 'run'
          sleep 1.0
        end
      end
    end

    doc.to_s
  end

  def proxy_kr2(params)
    doc = ""

    ourl = "http://redstone.logickorea.co.kr"
    murl = "http:\/\/redstone.logickorea.co.kr"
    purl = "https://papamira.herokuapp.com/proxy_kr2"
    iurl = "https://papamira.herokuapp.com/proxy_image"
    
    #ourl = "http://members.redsonline.jp"
    #murl = "http:\/\/members.redsonline.jp"
    #purl = "http://localhost:3000/proxy_kr2"
    #iurl = "http://localhost:3000/proxy_image"
    
    op = ""
    params.each do |key, val|
      if op.empty?
        op << "?#{key}=#{val}"
      else
        op << "&#{key}=#{val}"
      end
    end

    if op == "?ref="
      url = ourl
    else
      url = ourl +"/"+ op.gsub(/\?ref=\//, "")
    end

    css = []
    uri = Addressable::URI.parse(url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      response = http.get(uri.request_uri)
      body = response.body.toutf8
      doc = Nokogiri::HTML(body)
      
      doc.css('link').each do |anchor|
        if /\.css$/ =~ anchor[:href]
          url2 = ourl + anchor[:href]
          uri2 = Addressable::URI.parse(url2)
          Net::HTTP.start(uri2.host, uri2.port) do |http|
            response2 = http.get(uri2.request_uri)
            css_body = response2.body.toutf8

            css_body2 = ""
            css_body.split(/\r\n/).each do |t|
              if /url\(/ =~ t
                if /url\(((\/*\w)+\.(png|jpg|gif))\)/ =~ t
                  css_t = $1
                  img_url = "proxy_image?ref=" + css_t
                  t = t.gsub(css_t, img_url)
                end
              end
              css_body2 << t + "\n"
            end
            css.push(css_body2)
          end
        end
      end
      
      doc.css('img').each do |anchor|
        if /^http/ =~ anchor[:src]
          anchor[:src] = anchor[:src].split(/\//)[3..-1].join("/").to_s
          if /^\// !~ anchor[:src]
            anchor[:src] = "/" + anchor[:src]
          end
          url2 = iurl +"?ref="+ anchor[:src]
        else
          if /^\// !~ anchor[:src]
            anchor[:src] = "/" + anchor[:src]
          end
          url2 = iurl +"?ref="+ anchor[:src].gsub(/\.\/\/|\.\//, "/").gsub(/\/+/, "/")
        end
        anchor[:src] = url2
      end
    end

    body = doc.to_s.toutf8
    css.reverse_each do |text|
      rep = "<style>\n" + text.toutf8 + "</style>\n"
      body = body.gsub(/<link href="\/common_renew\/css\/top.css" rel="stylesheet" type="text\/css">/, rep)
      body = body.gsub(/<link href="\/common_renew\/css\/default.css" rel="stylesheet" type="text\/css">/, rep)

      body = body.gsub(/<link rel="stylesheet" href="\/css\/normalize.css">/, rep)
      body = body.gsub(/<link rel="stylesheet" href="\/css\/common.css">/, rep)
      body = body.gsub(/<link rel="stylesheet" href="\/css\/no_js.css">/, rep)
      body = body.gsub(/<link rel="stylesheet" href="\/board_style\/loginbox\/loginbox.css">/, rep)
      body = body.gsub(/<link rel="stylesheet" href="\/css\/main.css">/, rep)
    end

    body
  end

  def proxy_kr3(params)
    thread = []
    doc = ""
    ourl = "http://redstone.logickorea.co.kr"
    #ourl = "http://members.redsonline.jp"
    murl = "http:\/\/redstone.logickorea.co.kr"
    #murl = "http:\/\/members.redsonline.jp"
    purl = "https://papamira.herokuapp.com/proxy_kr3"
    #purl = "http://localhost:4567/proxy_kr"
    
    op = ""
    params.each do |key, val|
      if op.empty?
        op << "?#{key}=#{val}"
      else
        op << "&#{key}=#{val}"
      end
    end

    if op == "?ref="
      url = ourl
    else
      url = ourl +"/"+ op.gsub(/\?ref=\//, "")
    end

    body = ""
    uri = Addressable::URI.parse(url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      response = http.get(uri.request_uri)
      body = response.body.toutf8
      #doc = Nokogiri::HTML(body)
      #(doc/'script').remove
      #(doc/'comment').remove
      #(doc/'img').remove
    end
    #doc.to_s#.text
    body
  end

  def proxy_image(params)
    ourl = "http://redstone.logickorea.co.kr"
    murl = "http:\/\/redstone.logickorea.co.kr"
    purl = "https://papamira.herokuapp.com/proxy_image"
    
    #ourl = "http://members.redsonline.jp"
    #murl = "http:\/\/members.redsonline.jp"
    #purl = "http://localhost:4567/proxy_image"
    
    op = ""
    params.each do |key, val|
      if op.empty?
        op << "?#{key}=#{val}"
      else
        op << "&#{key}=#{val}"
      end
    end

    if op == "?ref="
      url = ourl
    else
      url = ourl +"/"+ op.gsub(/\?ref=\//, "")
    end

    body = ""
    uri = Addressable::URI.parse(url)
    Net::HTTP.start(uri.host, uri.port) do |http|
      response = http.get(uri.request_uri)
      body = response.body
    end

    case url
    when /\.png$/
      content_type :png
    when /\.jpg$/
      content_type :jpg
    when /\.gif$/
      content_type :gif
    end

    body
  end
end
