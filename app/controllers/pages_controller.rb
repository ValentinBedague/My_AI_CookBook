class PagesController < ApplicationController
  def home
    @collections = Collection.where(isfavorite: true)

    favorites_collection = Collection.find_by(name: "Favorites")
    @recipes = favorites_collection ? favorites_collection.recipes : []
  end
end
