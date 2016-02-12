class AddUidToComments < ActiveRecord::Migration
  def change
    add_column :comments, :uid, :string
  end
end
