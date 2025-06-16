class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :destroy, :ask_ai]

  require 'open-uri'

  STEPS = %w[name portions preptime ingredients instructions image create]
  SYSTEM_PROMPT = "You are a Cooking Assistant specialized in extracting recipes from images. You must strictly use the original words from the recipe found in the image. Do not paraphrase, invent or translate content."
  SYSTEM_PROMPT_URL = "You are a Cooking Assistant specialized in extracting recipes from text content extracted from cooking recipes webpages. You must strictly use the original words from the text content. Do not paraphrase, invent or translate content."

  def index
    @recipes = Recipe.all.order(:name)
    @grouped_recipes = @recipes.select { |r| r.name.present?}.group_by { |recipe| recipe.name[0].upcase }
  end

  def new
    @recipe = Recipe.new
    @step = STEPS.first
  end

  def show
  end

  def ask_ai
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
    @recipe = Recipe.new
    @recipe.user = current_user
    @recipe.save
    @url_prompt = <<~PROMPT
    You will receive the full text content extracted from a webpage containing a cooking recipe. Your task is to extract and return **only** the following five key elements in JSON format, with no additional text or commentary:

    1. The recipe name
    2. The number of servings (people the recipe is for)
    3. A list of ingredients
    4. Step-by-step preparation instructions
    5. The preparation time

    Return the data as a JSON object with the exact structure below:

    {
      "name": "Name of the recipe as a string (leave empty if not found)",
      "portions": "Number of servings as a string or integer (leave empty if not found)",
      "preparation_time": "Preparation time as an integer (in minutes, e.g., 30 for 30 minutes) (leave empty if not found)",
      "description": "An array of step-by-step instructions as strings (e.g., 'Do this', 'Then do that'). Leave empty if not found.",
      "ingredients": {
        "ingredient1": {
          "name": "Ingredient name as a string (leave empty if not found)",
          "quantity": "Quantity as a number (integer or float, e.g., 500 or 0.5) (leave empty if not found)",
          "unit": "Unit as a string (leave empty if not found or not applicable)"
        },
        "ingredient2": {
          "name": "Ingredient name as a string (leave empty if not found)",
          "quantity": "Quantity as a number (integer or float, e.g., 500 or 0.5) (leave empty if not found)",
          "unit": "Unit as a string (leave empty if not found or not applicable)"
        }
        # Add as many ingredients as needed, using the same structure
      }
    }

    ⚠️ Strict instructions:
    - If a piece of information is missing or not clearly visible in the image, leave the corresponding field empty. Do not guess or make assumptions.
    - Return **only** the final JSON object.
    - Do NOT include markdown code blocks or any formatting.
    - Do not include explanations, notes, or headers.
    - Ensure the JSON is syntactically valid.
PROMPT
    url = url_params[:url]
    html = URI.open(url).read
    doc = Nokogiri::HTML(html)
    doc.search('script, style, nav, header, footer, noscript, iframe, svg, link, meta, aside, form, button').remove
    rawtext = doc.text
    doctext = rawtext
      .gsub(/\s+/, ' ')
      .squeeze(' ')
      .strip

    @instruction = SYSTEM_PROMPT_URL
    @message = Message.new(role: "user", content: "#{@url_prompt}\n\n--- WEBPAGE TEXT BELOW ---\n\n#{doctext}", recipe: @recipe)
    @message.save
    @chat = RubyLLM.chat(model: "gpt-4o")
    response = @chat.with_instructions(@instruction).ask(@message.content)
    Message.create(role: "assistant", content: response.content, recipe: @recipe)

    json_response = Message.last.content
    data = JSON.parse(json_response)
    name = data["name"]
    portions = data["portions"]
    preparation_time = data["preparation_time"]
    description = data["description"]
    ingredients = data["ingredients"]

    ingredients.each do |key,ingredient|
      Ingredient.create(name: ingredient["name"], quantity: ingredient["quantity"], unit: ingredient["unit"], recipe_id: @recipe.id)
    end

    if @recipe.update(name: name, portions: portions, preparation_time: preparation_time, description: description, url_image: "https://www.ensto-ebs.fr/modules/custom/legrand_ecat/assets/img/no-image.png")
      redirect_to @recipe, notice: "#{@recipe.name} 🍽️ has been succesfully created ! ✅"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new_via_img
    @recipe = Recipe.new
  end

def create_via_img
    @recipe = Recipe.new(recipe_params)
    @recipe.user = current_user
    @recipe.save
    @img_prompt = <<~PROMPT
    You will receive an image of a cooking recipe. Your task is to extract and return **only** the following five key elements in JSON format, with no additional text or commentary:

    1. The recipe name
    2. The number of servings (people the recipe is for)
    3. A list of ingredients
    4. Step-by-step preparation instructions
    5. The preparation time

    Return the data as a JSON object with the exact structure below:

    {
      "name": "Name of the recipe as a string (leave empty if not found)",
      "portions": "Number of servings as a string or integer (leave empty if not found)",
      "preparation_time": "Preparation time as an integer (in minutes, e.g., 30 for 30 minutes) (leave empty if not found)",
      "description": "An array of step-by-step instructions as strings (e.g., 'Do this', 'Then do that'). Leave empty if not found.",
      "ingredients": {
        "ingredient1": {
          "name": "Ingredient name as a string (leave empty if not found)",
          "quantity": "Quantity as a number (integer or float, e.g., 500 or 0.5) (leave empty if not found)",
          "unit": "Unit as a string (leave empty if not found or not applicable)"
        },
        "ingredient2": {
          "name": "Ingredient name as a string (leave empty if not found)",
          "quantity": "Quantity as a number (integer or float, e.g., 500 or 0.5) (leave empty if not found)",
          "unit": "Unit as a string (leave empty if not found or not applicable)"
        }
        # Add as many ingredients as needed, using the same structure
      }
    }

    ⚠️ Strict instructions:
    - If a piece of information is missing or not clearly visible in the image, leave the corresponding field empty. Do not guess or make assumptions.
    - Return **only** the final JSON object.
    - Do not include explanations, notes, or headers.
    - Do NOT include markdown code blocks or any formatting.
    - Ensure the JSON is syntactically valid.
PROMPT
   @instruction =SYSTEM_PROMPT
   @message = Message.new(role:"user", content: @img_prompt, recipe: @recipe)
   @chat = RubyLLM.chat(model: "gpt-4o")
   response = @chat.with_instructions(@instruction).ask(@message.content, with: {image: @recipe.image})
   Message.create(role: "assistant", content: response.content, recipe: @recipe)

   json_response = Message.last.content
   data = JSON.parse(json_response)
   name = data["name"]
   portions = data["portions"]
   preparation_time = data["preparation_time"]
   description = data["description"]
   ingredients = data["ingredients"]

   ingredients.each do |key,ingredient|
    Ingredient.create(name: ingredient["name"], quantity: ingredient["quantity"], unit: ingredient["unit"], recipe_id: @recipe.id)
   end

   if @recipe.update(name: name, portions: portions, preparation_time: preparation_time, description: description, url_image: "https://www.ensto-ebs.fr/modules/custom/legrand_ecat/assets/img/no-image.png")
   redirect_to @recipe, notice: "#{@recipe.name} 🍽️ has been succesfully created ! ✅"
   else
     render :new, status: :unprocessable_entity
   end
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

  def toggle_favorite
    @recipe = Recipe.find(params[:id])
    favorite_collection = Collection.find_by(name: 'Favorites')

    if favorite_collection.recipes.include?(@recipe)
      favorite_collection.recipes.delete(@recipe)
      @favorited = false
    else
      favorite_collection.recipes << @recipe
      @favorited = true
    end

    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to recipe_path(@recipe) }
    end
  end

  private

  def set_recipe
    @recipe = Recipe.find(params[:id])
  end

  def recipe_params
    params.require(:recipe).permit(:name, :portions, :preparation_time, :url_image, :image, description: [], ingredients_attributes: [:id, :name, :quantity, :unit, :_destroy])
  end

  def last_step
    STEPS.last == @step
  end

  def next_step
    STEPS[STEPS.index(@step) + 1]
  end

  def url_params
    params.require(:url_form).permit(:url)
  end
end
