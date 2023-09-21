# -*- encoding: utf-8 -*-
class Proxy_RSK
  require 'nokogiri'
  require 'open-uri'
  require 'addressable/uri'
  require 'net/http'
  require 'fileutils'
  require 'base64'
  require 'kconv'

  Net::HTTP.version_1_2
  #FURL = 'http://members.redsonline.jp'
  FURL = 'https://redstone.logickorea.co.kr'
  PREFIX_LP = "public/"

  def initialize(html)
    doc = Nokogiri::HTML.parse(html)
  end

  def img_dl(html)
    doc = Nokogiri::HTML.parse(html, nil, "UTF-8")
    img_link = {}
    doc.css('img').each do |anchor|
      if not anchor[:src].nil?
        if not anchor[:src].empty?
          if /\.(png|jpg|gif)$/ =~ anchor[:src]
            if /\/\// !~ anchor[:src]
              img_link[anchor[:src]] = "cache/" + anchor[:src].split(/\//)[1..-1].join("/")
            else
              anchor[:src] = anchor[:src].gsub(/http:\/\/members\.redsonline.jp/, "")
              anchor[:src] = anchor[:src].gsub(/http:\/\/www\.redsonline\.jp/, "")
              img_link[anchor[:src]] = "cache/" + anchor[:src].split(/\//)[1..-1].join("/")
            end
          end
        end
      end
    end

    img_link.each do |key, val|
      uri = Addressable::URI.parse(FURL+key)
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.get(uri.request_uri)
        dirname = val.split(/\//)[0..-2].join("/")
        FileUtils.mkdir_p(PREFIX_LP+dirname)
        f = File.open(PREFIX_LP+val, "w")
        f.write(response.body)
        f.close
      end
    end
  end


  def js_dl(html)
    doc = Nokogiri::HTML.parse(html)
    js_link = {}
    doc.css('script').each do |anchor|
      if not anchor[:src].nil?
        if not anchor[:src].empty?
          if /\.js$/ =~ anchor[:src]
            if /\/\// !~ anchor[:src]
              js_link[anchor[:src]] = "cache/" + anchor[:src].split(/\//)[1..-1].join("/")
            end
          end
        end
      end
    end

    js_link.each do |key, val|
      uri = Addressable::URI.parse(FURL+key)
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.get(uri.request_uri)
        dirname = val.split(/\//)[0..-2].join("/")
        FileUtils.mkdir_p(PREFIX_LP+dirname)
        f = File.open(PREFIX_LP+val, "w")
        f.write(response.body.toutf8)
        f.close
      end
    end
  end

  def css_dl(html)
    doc = Nokogiri::HTML.parse(html)
    css_link = {}
    doc.css('link').each do |anchor|
      css_link[anchor[:href]] = "cache/" + anchor[:href].split(/\//)[1..-1].join("/")
    end

    css_link.each do |key, val|
      uri = Addressable::URI.parse(FURL+key)
      Net::HTTP.start(uri.host, uri.port) do |http|
        response = http.get(uri.request_uri)
        dirname = val.split(/\//)[0..-2].join("/")
        FileUtils.mkdir_p(PREFIX_LP+dirname)
        f = File.open(PREFIX_LP+val, "w")
        f.write(response.body.toutf8)
        f.close
      end
    end
  end

  def link_dl(html)
    doc = Nokogiri::HTML.parse(html)

    css_link = {}
    doc.css('link').each do |anchor|
      css_link[anchor[:href]] = "cache/" + anchor[:href].split(/\//)[1..-1].join("/")
    end
    
    css_link.each do |key, val|
      html = html.gsub(/#{key}/, val)
    end

    js_link = {}
    doc.css('script').each do |anchor|
      if not anchor[:src].nil?
        if not anchor[:src].empty?
          if /\.js$/ =~ anchor[:src]
            if /\/\// !~ anchor[:src]
              js_link[anchor[:src]] = "cache/" + anchor[:src].split(/\//)[1..-1].join("/")
            end
          end
        end
      end
    end
    
    js_link.each do |key, val|
      html = html.gsub(/#{key}/, val)
    end

    img_link = {}
    doc.css('img').each do |anchor|
      if not anchor[:src].nil?
        if not anchor[:src].empty?
          if /\.(png|jpg|gif)$/ =~ anchor[:src]
            if /\/\// !~ anchor[:src]
              img_link[anchor[:src]] = "cache/" + anchor[:src].split(/\//)[1..-1].join("/")
            end
          end
        end
      end
    end
    
    img_link.each do |key, val|
      html = html.gsub(/#{key}/, val)
    end

    html
  end

  def link_fetch(html)
    doc = Nokogiri::HTML.parse(html)
    org_url   = 'http://redstone.logickorea.co.kr/'
    move_url  = 'https://papamira.herokuapp.com/'
    move_para = 'dev2?ref='
    url = move_url + move_para

    #doc.css('a').each do |anchor|
    #  anchor[:href] = anchor[:href].gsub(/http(s*):\/\/redstone\.logickorea\.co\.kr/, "")
    #  anchor[:href] = anchor[:href].gsub(/^(\/+)|(\.\/+)/, "")
    #  anchor[:href] = url + anchor[:href]
    #end

    doc.css('img').each do |anchor|
      anchor[:src] = url + anchor[:src].gsub(/^\.\/+|^\/+/, "")
      #uri = Addressable::URI.parse(org_url + anchor[:src])
      #Net::HTTP.start(uri.host, uri.port) do |http|
      #  response = http.get(uri.request_uri)
      #  body = response.body
      #  case anchor[:src]
      #  when /\.png$/
      #    url_img = 'data:image/png;base64,' + Base64.encode64(body).gsub(/\n/, "")
      #  #when /\.jpg$/
      #  #  url_img = 'data:image/jpeg;base64,' + Base64.encode64(body).gsub(/\n/, "")
      #  #when /\.gif$/
      #  #  url_img = 'data:image/gif;base64,' + Base64.encode64(body).gsub(/\n/, "")
      #  else
      #    url_img = false
      #  end
      #  anchor[:src] = url_img if url_img != false
      #end
    end

    #doc.css('script').each do |anchor|
    #  anchor[:src] = "" if /^\// =~ anchor[:src]
    #end

    doc.to_s
  end
end

if __FILE__ == $0
  html = ""

  #uri = Addressable::URI.parse(Proxy_RSK::FURL)
  #Net::HTTP.start(uri.host, uri.port) do |http|
  #  response = http.get(uri.request_uri)
  #  html = response.body.toutf8
  #end
  html = File.open('../org.html').read

  prsk = Proxy_RSK.new(html)
  #prsk.img_dl(html)
  #prsk.css_dl(html)
  #prsk.js_dl(html)
  #puts prsk.link_dl(html)
  #puts prsk.link_fetch(html)
end
