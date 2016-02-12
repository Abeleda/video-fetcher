class AddIndexToVideos < ActiveRecord::Migration
  def change
    add_index :videos, :attachment
  end
end
