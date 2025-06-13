class PagesController < ApplicationController
  def home
    @collections = Collection.all
    @recipes = Recipe.all
  end
end
