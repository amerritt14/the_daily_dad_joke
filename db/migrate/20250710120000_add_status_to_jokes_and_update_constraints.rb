class AddStatusToJokesAndUpdateConstraints < ActiveRecord::Migration[8.0]
  def change
    # Add status column with default value
    add_column :jokes, :status, :string, default: 'pending', null: false
    
    # Add not null constraint to question column
    change_column_null :jokes, :question, false
    
    # Add index for status for better query performance
    add_index :jokes, :status
  end
end
