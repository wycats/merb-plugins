class DatabaseSessions < ActiveRecord::Migration
  def self.up
    create_table :sessions do |t|
      t.column :session_id, :string
      t.column :data,       :text
      t.column :created_at, :datetime
    end
    add_index :sessions, :session_id
  end

  def self.down
    remove_index :sessions, :session_id
    drop_table :sessions
  end
end