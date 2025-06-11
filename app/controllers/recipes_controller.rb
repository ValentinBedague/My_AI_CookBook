class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :destroy]
  def index
    @recipes = Recipe.all
  end

  def new
    @recipe = Recipe.new
  end

  def show

  end

  def create
     @recipe = Recipe.new(recipe_params)
    if @recipe.url_image == ""
      @recipe.url_image = "https://www.ensto-ebs.fr/modules/custom/legrand_ecat/assets/img/no-image.png"
    end
    if @recipe.save
      redirect_to @recipe, notice: "#{@recipe.name} recipe was successfully created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new_via_url
  end

  def create_via_url
  end

  def new_via_img
  end

  def create_via_img
  end

  def edit
  end

  def update
    if @recipe.update(recipe_params)
    redirect_to @recipe, notice: "#{@recipe.name} was successfully updated!"
   else
    render :edit, status: :unprocessable_entity
   end
  end

  def destroy
    @recipe = Recipe.find(params[:id])

    if @recipe.destroy
      redirect_to recipes_path, notice: "#{@recipe.name} was succesfully destroyed"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(:name, :portions, :ingredients, :url_image)
  end
end
