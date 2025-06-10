class CreateRecipes < ActiveRecord::Migration[7.1]
  def change
    create_table :recipes do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.integer :portions
      t.integer :portions_displayed
      t.string :description, array: true, default: []
      t.string :description_displayed, array: true, default: []
      t.integer :preparation_time
      t.string :url_image

      t.timestamps
    end
  end
end
