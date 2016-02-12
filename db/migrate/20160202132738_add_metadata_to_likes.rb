class AddMetadataToLikes < ActiveRecord::Migration
  def change
    add_column :likes, :views, :integer
    add_column :likes, :dislikes, :integer

  end
end
