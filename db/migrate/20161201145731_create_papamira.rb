class CreatePapamira < ActiveRecord::Migration[7.0]
  def change
    create_table :papamira_chats do |t|
      t.string :name
      t.string :body
      t.string :host
      t.string :time
    end

    create_table :papamira_items do |t|
      t.string :index
      t.string :name
    end

    create_table :papamira_userwords do |t|
      t.string :index
      t.string :name
    end

    create_table :papamira_worlds do |t|
      t.string :server
      t.string :date
      t.string :days
      t.string :tags
      t.string :body
    end
  end
end
