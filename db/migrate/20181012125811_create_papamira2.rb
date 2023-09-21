class CreatePapamira2 < ActiveRecord::Migration[7.0]
  def change
    create_table :papamira_yourshops do |t|
      t.string :data
      t.string :date
    end
  end
end
