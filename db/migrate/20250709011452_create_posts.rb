class CreatePosts < ActiveRecord::Migration[8.0]
  def change
    create_table :posts do |t|
      t.string :beehiiv_post_id
      t.references :joke, null: false, foreign_key: true

      t.timestamps
    end
  end
end
