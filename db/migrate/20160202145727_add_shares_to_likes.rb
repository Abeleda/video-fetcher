class AddSharesToLikes < ActiveRecord::Migration
  def change
    add_column :likes, :shares, :integer
  end
end
