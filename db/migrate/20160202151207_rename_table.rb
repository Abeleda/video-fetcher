class RenameTable < ActiveRecord::Migration
  def change
    rename_table :likes, :metadata
  end
end
