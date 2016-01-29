class CreateVideos < ActiveRecord::Migration
  def change
    create_table :videos do |t|
      t.references  :channel
      t.string      :title
      t.datetime    :published
      t.datetime    :modified
      t.integer     :duration
      t.timestamps null: false
    end
  end
end
