# -*- encoding: utf-8 -*-

ENV['APP_ENV'] = 'test'

require_relative '../app'
require 'test/unit'
require 'rack/test'

module Papamira
  class App < Sinatra::Base
    set :public_folder, "public"
    set :views, "views"

    enable :sessions
    helpers Sinatra::Cookies
  end
end

class PapamiraTest < Test::Unit::TestCase
  include Rack::Test::Methods

  def app
    Papamira::App
  end

  def test_route_top
    get '/'
    assert last_response.ok?
    assert last_response.body.include?("お叫びの収集サイトです。")
  end

  def test_route_update
    get '/update'
    assert last_response.ok?
    assert last_response.body.include?("過去のお知らせ、更新情報")
  end

  def test_route_help
    get '/help'
    assert last_response.ok?
    assert last_response.body.include?("ヘルプ")
    assert last_response.body.include?("ごにょごにょ")
  end

  def test_route_dev
    get '/dev'
    assert last_response.ok?
    assert last_response.body.include?("更新履歴")
  end

  def test_route_source
    get '/source'
    assert last_response.ok?
    assert last_response.body.include?("ダウンロード")
    assert last_response.body.include?("papamira lib")
    assert last_response.body.include?("papamira web")
  end

  def test_route_download
    get '/download/lib'
    assert last_response.ok?

    get '/download/web_old'
    assert last_response.ok?

    get '/download/web'
    assert last_response.ok?
  end

  def test_route_gui
    get '/gui'
    assert last_response.ok?
    assert last_response.body.include?("ぱぱみら for GUI版")
  end

  def test_route_gui_update
    get '/gui/update'
    assert last_response.ok?
    assert last_response.body.include?("ぱぱみら for GUI 更新情報")
  end

  def test_route_ranking
    get '/ranking'
    assert last_response.ok?
    assert last_response.body.include?("ランキング")
  end

  def test_route_words
    get '/words'
    assert last_response.ok?
    assert last_response.body.include?("最近の検索履歴")
  end

  def test_route_ppap
    SERVERS.each do |s|
      get "/#{s}/ppap"
      assert last_response.ok?
      assert last_response.body.include?("Logs")
    end
  end

  def test_route_stream
    SERVERS.each do |s|
      get "/#{s}/stream"
      assert last_response.ok?
      assert last_response.body.include?("Log Streaming")
    end
  end

  def test_route_info
    get '/info'
    assert last_response.ok?
    assert last_response.body.include?("叫び統計")
  end

  def test_route_infos
    SERVERS.each do |s|
      get "/#{s}/info"
      assert last_response.ok?
      assert last_response.body.include?("叫び統計")
    end
  end

  def test_route_form
    uuid = SecureRandom.uuid
    clear_cookies
    set_cookie "rack.session=#{uuid}"
    get '/form'
    assert last_response.ok?
    assert last_response.body.include?(uuid)
  end

  def test_route_404
    get '/404'
    assert last_response.ok? == false
    assert last_response.body == '404'
  end

  def test_api_v1_info_calendar
    get '/api/v1/info_calendar'
    assert last_response.ok?
    assert_equal(JSON.parse(last_response.body).empty?, false)
  end

  def test_api_v1_ranking
    get '/api/v1/ranking'
    assert last_response.ok?
    assert_equal(JSON.parse(last_response.body).empty?, false)
  end

  def test_api_v1_words
    get '/api/v1/words'
    assert last_response.ok?
    assert_equal(JSON.parse(last_response.body).empty?, false)
  end

  def test_api_v1_server_active
    req_0 = {"all"=>0, "b"=>"down", "g"=>"down", "s"=>"down", "v"=>"down"}
    req_4 = {"all"=>4, "b"=>"up", "g"=>"up", "s"=>"up", "v"=>"up"}

    get '/api/v1/server_active'
    assert last_response.ok?
    res = JSON.parse(last_response.body)
    if res['all'] == 0
      assert_equal(JSON.parse(last_response.body), req_0)
    else
      assert_equal(JSON.parse(last_response.body), req_4)
    end
  end

  def test_api_v1_all_web_connect
    get '/api/v1/web_connect_int'
    assert last_response.ok?
    assert_equal(JSON.parse(last_response.body), 0)
  end

  def test_api_v1_web_connect
    get '/api/v1/web_connect'
    assert last_response.ok?
    assert_equal(JSON.parse(last_response.body), "error Server Name no set.")

    get '/api/v1/web_connect', "server" => "x"
    assert last_response.ok?
    assert_equal(JSON.parse(last_response.body), "error Server Name.")

    SERVERS.each do |s|
      get '/api/v1/web_connect', "server" => s
      assert last_response.ok?
      assert_equal(JSON.parse(last_response.body), "0")
    end
  end

  def test_api_v1_web_connects
    req = {"all"=>0, "b"=>0, "g"=>0, "home"=>0, "s"=>0, "v"=>0}
    get '/api/v1/web_connects'
    assert last_response.ok?
    assert_equal(JSON.parse(last_response.body), req)
  end

  def test_api_v1_server_alive
    get '/api/v1/server_alive'
    assert last_response.ok?
    assert_equal(JSON.parse(last_response.body), "error Server Name no set.")

    get '/api/v1/server_alive', "server" => "x"
    assert last_response.ok?
    assert_equal(JSON.parse(last_response.body), "error Server Name.")

    SERVERS.each do |s|
      get '/api/v1/server_alive', "server" => s
      assert last_response.ok?
      assert_equal(JSON.parse(last_response.body), "up")
    end

    req = {"b"=>"up", "g"=>"up", "s"=>"up", "v"=>"up"}
    get '/api/v1/server_alive', "server" => "all"
    assert last_response.ok?
    assert_equal(JSON.parse(last_response.body), req)
  end

  def test_api_v1_server_power
    get '/api/v1/server_power'
    assert last_response.ok?
    assert_match(/(\d|,)+/, JSON.parse(last_response.body))
  end

  def test_api_v1_voice_dic
    get '/api/v1/voice_dic'
    assert last_response.ok?
    assert_equal(JSON.parse(last_response.body), JSON.parse(File.open("data/web_speech.dic").read))
  end

  def test_api_v1_ppap_shout
    get '/api/v1/ppap_shout'
    assert last_response.ok?
  end

  def test_api_v1_version
    get '/api/v1/version'
    assert last_response.ok?
    assert_equal(JSON.parse(last_response.body), Papamira_Status.Version)
  end

  def test_route_json_post
    pdata = []

    now = DateTime.now.strftime("%Y/%m/%d %H:%M:%S")
    pdata.push(%Q!{"stat":"wt","date":"#{now}","name":"wTestUser_s","body":"買) sテスト叫び1","key":"0001"}!)
    pdata.push(%Q!{"stat":"wt","date":"#{now}","name":"wTestUser_v","body":"買) vテスト叫び2","key":"0002"}!)
    pdata.push(%Q!{"stat":"wt","date":"#{now}","name":"wTestUser_b","body":"買) bテスト叫び3","key":"0003"}!)
    pdata.push(%Q!{"stat":"wt","date":"#{now}","name":"wTestUser_g","body":"買) gテスト叫び4","key":"0004"}!)

    now = DateTime.now.strftime("%Y/%m/%d %H:%M:%S")
    pdata.push(%Q!{"stat":"sh","date":"#{now}","name":"sTestUser_s","body":"売) sテスト叫び5","key":"0001"}!)
    pdata.push(%Q!{"stat":"sh","date":"#{now}","name":"sTestUser_v","body":"売) vテスト叫び6","key":"0002"}!)
    pdata.push(%Q!{"stat":"sh","date":"#{now}","name":"sTestUser_b","body":"売) bテスト叫び7","key":"0003"}!)
    pdata.push(%Q!{"stat":"sh","date":"#{now}","name":"sTestUser_g","body":"売) gテスト叫び8","key":"0004"}!)

    pdata.each do |json|
      post '/push2', json
      assert last_response.ok?
      assert_equal(last_response.body, "true")
    end
  end
end
