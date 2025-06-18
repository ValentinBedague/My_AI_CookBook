class AddIsfavoriteToCollections < ActiveRecord::Migration[7.1]
  def change
    add_column :collections, :isfavorite, :boolean, default: false
  end
end
