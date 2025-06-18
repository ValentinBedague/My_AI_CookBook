class AddUserToCollections < ActiveRecord::Migration[7.1]
  def change
    # Step 1: add user_id column without NOT NULL
    add_reference :collections, :user, null: true, foreign_key: true

    # Step 3: change column to NOT NULL
    change_column_null :collections, :user_id, false
  end
end
