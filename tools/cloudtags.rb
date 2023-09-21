# -*- encoding: utf-8 -*-
require 'natto'
require 'date'
require 'nkf'

def check_int(text)
  case text
  when /^\d+$/
    true
  when /^(\s)+|(\W_)+|(!)+$/
    true
  else
    false
  end
end

#nm = Natto::MeCab.new('-Oyomi')
nm = Natto::MeCab.new("-Ochasen")

ref = ""
all_map = {}
date_now = ""
date_last = ""
date_week = ""

File.open(ARGV[0]).read.split(/\n/).reverse_each do |data|
  tmp = data.split(/ /)
  date = tmp[1..2].join(" ")
  data2 = NKF.nkf("-w", tmp[4..-1].join(""))

  if date_last == ""
    date_last = Date.parse(date)
    date_week = Date.parse(date) - 30
  end
  date_now = Date.parse(date)

  break if date_now < date_week

  if not data2.nil? and not data2.empty?
    nm.parse(data2) do |n|
      if /^名詞/ =~ n.feature.split(/\s/)[3]
        all_map[n.surface] = all_map[n.surface] ? all_map[n.surface] + 1 : 1
      end
    end
  end
end

i = 0
all_map.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }.each do |tags, val|
  if tags.size >= 3
    if val >= 10
      if not check_int(tags)
        #ref << ltags+":"+val.to_s+"\n"
        ref << tags+"\n"
        i+=1
      end
    end
    #break if i >= 1000
  end
end
puts ref
