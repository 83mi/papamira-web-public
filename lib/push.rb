# -*- encoding: utf-8 -*-

class PapamiraPusher
  def PapamiraPusher::push_sync(params, w_clients)
    web_peoples = 0
    dep_flg = false

    w_clients.each do |client| 
      web_peoples += 1
    end

    w_clients.each do |client|
      s = client.env['REQUEST_URI'].scan(/^\/(s|b|v|g|all)\/(stream|ppap)$/).flatten[0]
      if API_KEY[s] == params['key'] or client.env['REQUEST_URI'] == '/' or s == 'all'
        params2 = params.dup
        speak_body = ""

        if s == 'all'
          rserver = ''
          API_KEY.each do |server_name, api_key|
            if api_key == params2['key']
              rserver = server_name
            end
          end
          params2['server'] = rserver
        end

        if client.env['REQUEST_URI'] == '/'
          params2['page'] = ''
          params2['stat'] = ''
          params2['name'] = ''
          params2['date'] = ''
          params2['search_name'] = ''
          params2['search_body'] = ''
          params2.delete('page')
          params2.delete('stat')
          params2.delete('name')
          params2.delete('date')
          params2.delete('search_name')
          params2.delete('search_body')
        else
          begin
            if params['body'].size != 0
              case s
              when 'all'
                speak_body = "#{rserver}鯖 " + params['body']
                params2['web_people'] = web_peoples
              when 's', 'b', 'v', 'g'
                speak_body = params['body']
                params2['web_people'] = web_peoples
              else
                speak_body = params['body']
              end

              store_path = TextToVoicePub::make_text2voice_public(speak_body)
              if store_path.empty?
                params2['store_audio'] = ''
                params2.delete('store_audio')
              else
                params2['store_audio'] = store_path
              end
            else
              case s
              when 'all', 's', 'b', 'v', 'g'
                params2['web_people'] = web_peoples
              end
            end
          rescue
            case s
            when 'all', 's', 'b', 'v', 'g'
              params2['web_people'] = web_peoples
            end
            params2['store_audio'] = ''
            params2.delete('store_audio')
          end
        end

        params2['key'] = ''
        params2.delete('key')
        client.send(JSON.generate(params2))
      end
    end

    return true
  end
end
