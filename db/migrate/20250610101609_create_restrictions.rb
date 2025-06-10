class CreateRestrictions < ActiveRecord::Migration[7.1]
  def change
    create_table :restrictions do |t|
      t.jsonb :diet
      t.string :ingredients, array: true, default: []
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
