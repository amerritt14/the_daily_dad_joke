class RenameJokeColumns < ActiveRecord::Migration[8.0]
  def change
    rename_column :jokes, :question, :prompt
    rename_column :jokes, :answer, :punchline
  end
end
