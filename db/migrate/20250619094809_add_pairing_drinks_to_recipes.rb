class AddPairingDrinksToRecipes < ActiveRecord::Migration[7.1]
  def change
    add_column :recipes, :pairing_drinks, :jsonb
  end
end
