class CreatePapamiara < ActiveRecord::Migration[7.0]
  def change
    create_table :papamira_search_words do |t|
      t.string :server
      t.string :data
    end
  end
end
