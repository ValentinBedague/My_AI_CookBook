class AddOriginalRecipeIdToRecipes < ActiveRecord::Migration[7.1]
  def change
    add_column :recipes, :original_recipe_id, :integer
  end
end
