class CreateShouts < ActiveRecord::Migration[7.0]
  def change
    create_table :papamira_shouts do |t|
      t.string :stat
      t.string :server, null: false
      t.string :days, null: false
      t.string :date, null: false
      t.string :name, null: false
      t.string :body
    end
  end
end
