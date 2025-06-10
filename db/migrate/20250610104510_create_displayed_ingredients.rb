class CreateDisplayedIngredients < ActiveRecord::Migration[7.1]
  def change
    create_table :displayed_ingredients do |t|
      t.string :name
      t.float :quantity
      t.string :unit
      t.references :recipe, null: false, foreign_key: true

      t.timestamps
    end
  end
end
