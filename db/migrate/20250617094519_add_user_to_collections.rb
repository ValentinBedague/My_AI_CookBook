class AddUserToCollections < ActiveRecord::Migration[7.1]
  def change
    # Step 1: add user_id column without NOT NULL
    add_reference :collections, :user, null: true, foreign_key: true

    # Step 2: Backfill user_id values for existing collections
    reversible do |dir|
      dir.up do
        # Assign all existing collections to user_id = 5 (remilebogoss)
        execute <<-SQL.squish
          UPDATE collections SET user_id = 5 WHERE user_id IS NULL;
        SQL
      end
    end

    # Step 3: change column to NOT NULL
    change_column_null :collections, :user_id, false
  end
end
