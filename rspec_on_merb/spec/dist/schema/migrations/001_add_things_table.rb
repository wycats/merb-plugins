class AddThingsTable < ActiveRecord::Migration
  def self.up
    create_table :things, :force => true do |t|
        t.column :name, :string
    end
  end

  def self.down
    drop_table :things
  end
end
