require 'json'
require 'uri'
require 'net/https'

class TextToVoice
  class BadRequest < StandardError; end
  class Unauthoeized < StandardError; end

  ENDPOINT = URI('https://api.voicetext.jp/v1/tts')
  EMOTION_LEVEL = { normal: "1", high: "2"  }

  def initialize(api_key)
    @api_key = api_key
    @speaker = "haruka"
    @pitch = "100"
    @speed = "100"
    @volume = "100"
    @format = "wav"
  end

  def speaker(speaker_name)
    @speaker = speaker_name
    self
  end

  def emotion(emotion:, level: :normal)
    @emotion = emotion.to_s
    @emotion_level = EMOTION_LEVEL[level]
    self
  end

  def pitch(param)
    @pitch = param.to_s
    self
  end

  def speed(param)
    @speed = param.to_s
    self
  end

  def volume(param)
    @volume = param.to_s
    self
  end

  def speak(text)
    @text = text2dic(text)
    #@text = text
    self
  end

  def format(text)
    @format = text
    self
  end

  def text2dic(text)
    text2 = text
    TextToVoiceDicData::DIC.each do |key, val|
      key = key.gsub(/\|\?|\)|\(|\&/) { |word| "\\#{word}" }
      text2 = text2.gsub(/#{key}/, val)
    end
    return text2
  end

  def save_as(filename)
    res = send_request()

    case res
    when Net::HTTPOK
      binary_to_wav(filename, res.body)
    when Net::HTTPBadRequest
      raise BadRequest.new(res.body)
    when Net::HTTPUnauthorized
      raise Unauthoeized.new(res.body)
    else
      raise StandardError.new(res.body)
    end
  end

  private

  def create_request(text, speaker, emotion, emotion_level, pitch, speed, volume, format)
    req = Net::HTTP::Post.new(ENDPOINT.path)
    req.basic_auth(@api_key, '')
    data = "text=#{text2dic(text)}"
    data << ";speaker=#{speaker}"
    data << ";emotion=#{emotion}"
    data << ";emotion_level=#{emotion_level}"
    data << ";pitch=#{pitch}"
    data << ";speed=#{speed}"
    data << ";volume=#{volume}"
    data << ";format=#{format}"
    req.body = data

    return req
  end

  def send_request
    res = nil
    https = Net::HTTP.new(ENDPOINT.host, 443)
    https.use_ssl = true
    https.start do |https|
      req = create_request(@text, @speaker, @emotion, @emotion_level, @pitch, @speed, @volume, @format)
      res = https.request(req)
    end

    return res
  end

  def binary_to_wav(filename, binary)
    File.open("#{filename}", "w") do |io|
      io.binmode
      io.write binary
    end
  end
end

class TextToVoiceDicData
  dic_file = 'data/web_api.dic'
  if File.exist?(dic_file)
    DIC = JSON.parse(File.open(dic_file).read)
  else
    DIC = {
      "買】"  => "かい ",
      "買)"   => "かい ",
      "買\）" => "かい ",
      "売)"   => "うり ",
      "売\）" => "うり ",
      "売】"  => "うり ",
      "買 "   => "かい ",
      "売 "   => "うり ",
      "買　"  => "かい ",
      "売　"  => "うり ",
      "〆"    => "しめ",
      "＠"    => "あと",
      "@"     => "あと",
      "&"     => "あんど",
      "ｍ"    => "えむ",
      "Ｍ"    => "えむ",
      "金再構成" => "きん再構成",
      "金増幅" => "きん増幅",
      "ＷＩＺ" => "うぃず",
      "wiz" => "うぃず",
      "ｂｉｓ" => "びぃず",
      "bis" => "びぃず",
      "ｓ" => "さん",
    }
  end
end

class TextToVoicePub
  def TextToVoicePub::p2d_text2voice(path)
    $store_audio.push(path)
    if $store_audio.size > 30
      if File.exist?('/tmp/' + $store_audio.first)
        File.delete('/tmp/' + $store_audio.first)
      end
      $store_audio.shift
    end
  end

  def TextToVoicePub::make_text2voice_raw(body)
    ext = 'mp3'
    path = '/tmp/'
    md5_name = Digest::MD5.hexdigest(body).to_s

    if File.exist?(path + md5_name + '.' + ext)
      return (path + md5_name + '.' + ext)
    else
      voice = TextToVoice.new(API_KEY['voice'])
      voice.speak(body)
        .speaker("hikari")
        .speed("100")
        .format(ext)
        .emotion(emotion: :happiness, level: :high)

      full_path = path + md5_name + ".#{ext}"
      voice.save_as(full_path)
      p2d_text2voice(full_path)
      return full_path
    end
  end

  def TextToVoicePub::make_text2voice_public(body)
    full_path = self.make_text2voice_raw(body)
    if File.exist?(full_path)
      public_path = '/store/'
      return full_path.sub(/^\/tmp\//, public_path).sub(/\.mp3$/, "")
    else
      return ""
    end
  end
end
