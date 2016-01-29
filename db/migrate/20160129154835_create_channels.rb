class CreateChannels < ActiveRecord::Migration
  def change
    create_table :channels do |t|
      t.references :partner
      t.string :name
      t.string :url
      t.integer :platform, limit: 1
      t.integer :frequency
      t.timestamps null: false
    end
  end
end
