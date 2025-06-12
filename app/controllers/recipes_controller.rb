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
    @recipe = Recipe.new
    @img_prompt = <<~PROMPT
      You will receive an image of a cooking recipe. Your task is to extract and return only the following five key elements in a valid Ruby hash (not JSON), with no additional text or commentary:

      1. The recipe name
      2. The number of servings (people the recipe is for)
      3. A list of ingredients
      4. Step-by-step preparation instructions
      5. The preparation time

      Return the data exactly in the following Ruby hash format:

      {
        name: "Name of the recipe as a string (leave empty if not found)",
        portions: "Number of servings as an integer (leave empty if not found)",
        preparation_time: "Preparation time as an integer (in minutes, e.g., 30 for 30 minutes) (leave empty if not found)",
        description: "Step-by-step instructions, using numbered steps (e.g., '1. ..., 2. ...') (leave empty if not found)",
        ingredients: {
          ingredient1: {
            name: "Ingredient name as a string (leave empty if not found)",
            quantity: "Quantity as a number (e.g., 500 from '500g') (leave empty if not found)",
            unit: "Unit as a string (e.g., 'g') (leave empty if not found or not applicable)"
          },
          ingredient2: {
            name: "Ingredient name as a string (leave empty if not found)",
            quantity: "Quantity as a number (e.g., 500 from '500g') (leave empty if not found)",
            unit: "Unit as a string (e.g., 'g') (leave empty if not found or not applicable)"
          }
          # Add as many ingredients as needed, using the same structure
        }
      }

      ⚠️ Strict instructions:
      - If a piece of information is missing or not clearly visible in the image, leave the corresponding field empty. Do not guess or make assumptions.
      - Return only the final Ruby hash.
      - Do not include explanations, notes, or headers.
      - Ensure the hash is syntactically valid.
PROMPT

  end

  def create_via_img
    @recipe = Recipe.create(recipe_params)
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
    params.require(:recipe).permit(:name, :portions, :description, :preparation_time :url_image, :image)
  end
end
