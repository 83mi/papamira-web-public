class AddFullTextSearchIndexToWords < ActiveRecord::Migration[7.0]
  def change
    add_index(:papamira_shouts, :body, using: "pgroonga")
    add_index(:papamira_shouts, :name, using: "pgroonga")
  end
end
