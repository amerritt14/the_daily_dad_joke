class AddColumnsToJoke < ActiveRecord::Migration[8.0]
  def change
    add_column :jokes, :source, :string
    add_column :jokes, :source_id, :string
  end
end
