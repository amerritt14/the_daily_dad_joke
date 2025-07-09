class CreateJokes < ActiveRecord::Migration[8.0]
  def change
    create_table :jokes do |t|
      t.string :question
      t.string :answer

      t.timestamps
    end
  end
end
