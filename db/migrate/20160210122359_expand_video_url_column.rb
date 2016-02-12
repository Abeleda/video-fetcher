class ExpandVideoUrlColumn < ActiveRecord::Migration
  def change
    remove_column :videos, :url
    add_column :videos, :url, :text
  end
end
