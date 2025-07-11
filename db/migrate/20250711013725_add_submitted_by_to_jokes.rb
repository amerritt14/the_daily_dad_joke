class AddSubmittedByToJokes < ActiveRecord::Migration[8.0]
  def change
    add_column :jokes, :submitted_by, :string
  end
end
