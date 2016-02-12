class RenameColumns < ActiveRecord::Migration
  def change
    rename_column :metadata, :amount, :likes
  end
end
