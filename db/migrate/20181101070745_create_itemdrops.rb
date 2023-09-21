class CreateItemdrops < ActiveRecord::Migration[7.0]
  def change
    create_table :papamira_itemdrops do |t|
      t.string :data
    end
  end
end
