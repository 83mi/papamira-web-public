class CreateSearchWordDays < ActiveRecord::Migration[7.0]
  def change
    create_table :papamira_search_word_days do |t|
      t.string :server
      t.string :days
      t.string :name
      t.string :count, null: 1
    end
  end
end
