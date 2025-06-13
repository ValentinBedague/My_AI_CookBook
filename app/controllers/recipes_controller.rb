class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :destroy]

  STEPS = %w[name portions preptime ingredients instructions image create]

  def index
    @recipes = Recipe.all
  end

  def new
    @recipe = Recipe.new
    @step = STEPS.first
  end

  def show
  end

  def create
    if params[:id]
      @recipe = Recipe.find(params[:id])
      @recipe.assign_attributes(recipe_params)
    else
      @recipe = Recipe.new(recipe_params)
      @recipe.user = current_user
      @recipe.ingredients.build if @recipe.ingredients.empty?
    end
    @step = params[:step]
    @recipe.save(validate: false)
    if last_step
      @recipe.save!
      redirect_to recipe_path(@recipe), notice: "Recipe created successfully!"
    else
      # Move to next step
      @step = next_step
      Rails.logger.info "Current step: #{@step.inspect}"
      Rails.logger.info "Next step: #{next_step.inspect}"
      respond_to do |format|
        format.html { render :new }
        format.turbo_stream do
          render turbo_stream: turbo_stream.replace(
            "recipe_form_container",
            partial: "recipes/form_steps/#{@step}",
            locals: { recipe: @recipe }
          )
        end
      end
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
    params.require(:recipe).permit(:name, :portions, :preparation_time, :url_image, description: [], ingredients_attributes: [:id, :name, :quantity, :unit, :_destroy])
  end

  def last_step
    STEPS.last == @step
  end

  def next_step
    STEPS[STEPS.index(@step) + 1]
  end
end
