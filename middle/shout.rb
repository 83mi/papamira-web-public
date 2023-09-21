#!/usr/bin/ruby1.8
# -*- encoding: ascii-8bit -*-
# papamira libs Version 1.0.1
#
$KCODE = "C" if RUBY_VERSION.to_s <= "1.8.7"

# ex: CLIENT_IP='192.168.11.100'
CLIENT_IP=''
KEY=''
PUSH_URL=''
MARGE_URL=''

require 'nkf'
require 'kconv'
require 'time'

if /mingw|cygwin|mswin/ =~ RUBY_PLATFORM.downcase
  require 'pcaprub'
else
  if RUBY_VERSION.to_s <= "1.8.7"
    require 'pcap'
  else
    require 'pcaprub'
  end
end

if ARGV[0].nil?
  if /mingw|cygwin|mswin/ =~ RUBY_PLATFORM.downcase
    output = "C:\\wt.log"
  else
    output = "/tmp/wt.log"
  end
else
  output = ARGV[0]
end

if ARGV[1].nil?
  netdev = 0
else
  netdev = ARGV[1].to_i
end

class PPAPCaptureFilter
  def initialize
  end
  # sakebi
  SHOUT =      "\000X\021\314\314\314\314..\f\301"

  # WT
  WORLDSHOUT = "\000X\021\314\314\314\314\314\314\f\304"
end

class PPAPCaptureUtility
  def initialize
    @day = Time.now
  end

  def create_days
    day = Time.now
    ymd = [day.year, sprintf("%02d", day.month.to_s), sprintf("%02d", day.day.to_s)].join("/")
    hms = [sprintf("%02d", day.hour.to_s), sprintf("%02d", day.min.to_s), sprintf("%02d", day.sec.to_s)].join(":")
    yhs = [ymd, hms].join(" ")
    return yhs
  end

  def init_times
    @day
  end
end

class PPAPCapture
  def initialize(dev="eth0")
    if /mingw|cygwin|mswin/ =~ RUBY_PLATFORM.downcase
      @pcaplet = Pcap::open_live(dev, 65536, true, 100)
      if CLIENT_IP.empty?
        @access = 'port 54631 || port 56621'
      else
        @access = "(port 54631 and dst host #{CLIENT_IP}) || (port 56621 and dst host #{CLIENT_IP})"
      end
      p @access
    else
      @pcaplet = Pcap::Capture.open_live(dev, 65536, true, 100)
      if CLIENT_IP.empty?
        @access = Pcap::Filter.new('port 54631 || port 56621', @pcaplet)
      else
        @access = Pcap::Filter.new("port 54631 and dst host #{CLIENT_IP}|| port 56621 and dst host #{CLIENT_IP}", @pcaplet)
      end
    end
  end

  def capture_data(interval, output="/tmp/wt.log")
    i = 0;
    @marge_data = ""
    @days = PPAPCaptureUtility.new
    @pcaplet.setfilter(@access);
    @pcaplet.each_packet do |pkt|
      if /mingw|cygwin|mswin/ =~ RUBY_PLATFORM.downcase
        capture_data_run(pkt.to_s, output)
        i += 1;
      else
        if pkt.tcp_data_len > 0 then
          data = pkt.tcp_data
          capture_data_run(data, output)
          i += 1;
        end
      end
      if interval != 0
        break if i>interval;
      end
    end
    pcaplet.close
  end

  def capture_data_run(data, output="/tmp/wt.log")
    case data
    when /#{PPAPCaptureFilter::SHOUT}/
      d5 = data.dup
      self.capture_save_print(self.capture_data_shout(d5), output)
    when /#{PPAPCaptureFilter::WORLDSHOUT}/
      d6 = data.dup
      self.capture_save_print(self.capture_data_worldshout(d6), output)
    end
  end

  def capture_data_shout(data)
    ref = {}

    if /mingw|cygwin|mswin/ =~ RUBY_PLATFORM.downcase
      head = "叫び: ".tosjis.force_encoding("Windows-31J")
      ffsep1 = " 【".tosjis.force_encoding("Windows-31J")
      ffsep2 = "】 ".tosjis.force_encoding("Windows-31J")
      iosep1 = " [".tosjis.force_encoding("Windows-31J")
      iosep2 = "] ".tosjis.force_encoding("Windows-31J")
    else
      head = "叫び: ".tosjis
      ffsep1 = " 【".tosjis
      ffsep2 = "】 ".tosjis
      iosep1 = " [".tosjis
      iosep2 = "] ".tosjis
    end

    yh = @days.create_days
    b = data.split(/#{PPAPCaptureFilter::SHOUT}/)[1].split(/\000/)
    name = b[0].to_s
    body = b[1].to_s

    name = name.to_s.sub(/^\|/, "")

    if /mingw|cygwin|mswin/ =~ RUBY_PLATFORM.downcase
      head.force_encoding("Windows-31J")
      name.force_encoding("Windows-31J")
      body.force_encoding("Windows-31J")
    end

    if not name.nil? and not body.nil?
      ref['file']   = head + yh + ffsep1 + name + ffsep2 + body
      ref['output'] = head + yh + iosep1 + name + iosep2 + body
      if @marge_data == name.to_s + body.to_s
        ref = {}
      else
        @marge_data = name.to_s + body.to_s
      end
    end
    return ref
  end

  def capture_data_worldshout(data)
    ref = {}

    if /mingw|cygwin|mswin/ =~ RUBY_PLATFORM.downcase
      head = "Wt: ".tosjis.force_encoding("Windows-31J")
      ffsep1 = " 【".tosjis.force_encoding("Windows-31J")
      ffsep2 = "】 ".tosjis.force_encoding("Windows-31J")
      iosep1 = " [".tosjis.force_encoding("Windows-31J")
      iosep2 = "] ".tosjis.force_encoding("Windows-31J")
    else
      head = "Wt: ".tosjis
      ffsep1 = " 【".tosjis
      ffsep2 = "】 ".tosjis
      iosep1 = " [".tosjis
      iosep2 = "] ".tosjis
    end

    yh = @days.create_days
    b = data.split(/#{PPAPCaptureFilter::WORLDSHOUT}/)[1].split(/\000/)
    name = b[0].to_s
    body = b[1].to_s

    name = name.sub(/^\|/, "")

    if /mingw|cygwin|mswin/ =~ RUBY_PLATFORM.downcase
      head.force_encoding("Windows-31J")
      name.force_encoding("Windows-31J")
      body.force_encoding("Windows-31J")
    end

    if not name.nil? or not body.nil?
      ref['file']   = head + yh + ffsep1 + name + ffsep2 + body
      ref['output'] = head + yh + iosep1 + name + iosep2 + body
      if @marge_data == name.to_s + body.to_s
        ref = {}
      else
        @marge_data = name.to_s + body.to_s
      end
    end

    return ref
  end

  def capture_save(body, output)
    if body.empty? == false
      File.open(output,"a") do |file|
        if /mingw|cygwin|mswin/ =~ RUBY_PLATFORM.downcase
          file.puts(NKF.nkf("-xs", body['file']) + "\n")
        else
          file.puts(NKF.nkf("-xw", body['file']) + "\n")
        end
      end
    end
  end

  def capture_save_print(body, output)
    if body.empty? == false
      File.open(output,"a") do |file|
        if /mingw|cygwin|mswin/ =~ RUBY_PLATFORM.downcase
          file.puts(NKF.nkf("-xs", body['file']) + "\n")
        else
          file.puts(NKF.nkf("-xw", body['file']) + "\n")
        end
      end
      if /mingw|cygwin|mswin/ =~ RUBY_PLATFORM.downcase
        puts NKF.nkf("-xs", body['output'])
      else
        puts NKF.nkf("-xw", body['output'])
      end
    end
  end
end

if __FILE__ == $0
  begin
    if /mingw|cygwin|mswin/ =~ RUBY_PLATFORM.downcase
      devs = []
      Pcap::findalldevs.each do |name, dest|
        puts name + ": " + dest
        devs.push(name)
      end
      cmain = PPAPCapture.new(devs[netdev])
    else
      cmain = PPAPCapture.new("ppp0")
    end
    cmain.capture_data(0, output);
    sleep 1.0
  rescue
    retry
  end
end
