# -*- encoding: utf-8 -*-
require 'natto'
require 'date'
require 'nkf'
require 'json'

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

nm = Natto::MeCab.new("-Ochasen")

ref = []
all_map = {}
date_now = ""
date_last = ""
date_week = ""

JSON.parse(File.open(ARGV[0]).read).reverse_each do |data|
  data2 = data['body']
  nm.parse(data2) do |n|
    if /^名詞/ =~ n.feature.split(/\s/)[3]
      all_map[n.surface] = all_map[n.surface] ? all_map[n.surface] + 1 : 1
    end
  end
end

all_map.sort {|(k1, v1), (k2, v2)| v2 <=> v1 }.each do |tags, val|
  if tags.size >= 2
    if not check_int(tags)
      ref.push(tags)
    end
  end
end
puts JSON.pretty_generate(ref)
