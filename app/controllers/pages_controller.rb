class PagesController < ApplicationController
  def home
    @collections = Collection.all

    favorites_collection = Collection.find_by(name: "Favorites")
    @recipes = favorites_collection ? favorites_collection.recipes : []
  end
end
