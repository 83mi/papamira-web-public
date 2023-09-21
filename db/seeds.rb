# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

require "csv"

PapamiraItem.destroy_all
ActiveRecord::Base.connection.execute("select setval ('papamira_items_id_seq', 1, false)")

CSV.foreach('data/item.dat') do |row|
  PapamiraItem.create(:name => row[0])
end

PapamiraUserWord.destroy_all
ActiveRecord::Base.connection.execute("select setval ('papamira_user_words_id_seq', 1, false)")

CSV.foreach('data/complete.dat') do |row|
  PapamiraUserWord.create(:name => row[0])
end
