class FixComments < ActiveRecord::Migration
  def change
    remove_column :likes, :comments
    add_column :likes, :comments, :integer
  end
end
