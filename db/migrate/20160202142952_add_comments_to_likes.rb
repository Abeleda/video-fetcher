class AddCommentsToLikes < ActiveRecord::Migration
  def change
    add_column :likes, :comments, :string
  end
end
