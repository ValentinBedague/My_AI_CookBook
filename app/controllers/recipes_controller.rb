class RecipesController < ApplicationController
  before_action :set_recipe, only: [:show, :edit, :destroy, :ask_ai, :create_low_calories]

  require 'open-uri'

  STEPS = %w[name portions preptime ingredients instructions image create]
  SYSTEM_PROMPT = "You are a Cooking Assistant specialized in extracting recipes from images. You must strictly use the original words from the recipe found in the image. Do not paraphrase, invent or translate content."
  SYSTEM_PROMPT_URL = "You are a Cooking Assistant specialized in extracting recipes from text content extracted from cooking recipes webpages. You must strictly use the original words from the text content. Do not paraphrase, invent or translate content."
  SYSTEM_PROMPT_LOWCAL = "You are a Cooking Assistant specialized in reducing the calories of recipes. You must strictly use the original words from the recipe found in the image. Do not paraphrase, invent or translate content."

  def index
    if params[:query].present?
      terms = params[:query].split
      @recipes = Recipe.left_joins(:ingredients)
      terms.each do |term|
        @recipes = @recipes.where("recipes.name ILIKE :term OR ingredients.name ILIKE :term", term: "%#{term}%")
      end
      @recipes = @recipes.distinct.order(:name)
    else
      @recipes = Recipe.all.order(:name)
    end
    @grouped_recipes = @recipes.select { |r| r.name.present?}.group_by { |recipe| recipe.name[0].upcase }
  end

  def new
    @recipe = Recipe.new
    @step = STEPS.first
  end

  def show
  end

  def create_low_calories
    @new_recipe = Recipe.new
    @new_recipe.user = current_user
    @new_recipe.save
    ingredients_json = @recipe.ingredients.to_json
    @low_cal_prompt = <<~PROMPT
    You will receive information about a cooking recipe.

    Your task is to transform this recipe into a much lower-calorie version, while keeping the number of servings exactly the same. Do not reduce the total quantity of food to lower the calories. Instead, focus on replacing high-calorie ingredients with lower-calorie alternatives.

    Whenever possible, prefer natural substitutions over simply using “light” or reduced-fat versions of the same ingredient. For example, in a cake recipe, you could replace butter with grated carrot, zucchini, or sweet potato if they help reduce calories.

    🛠️ Make sure to update the step-by-step instructions accordingly to reflect the ingredient changes. These instructions must remain coherent with the new set of ingredients.

    Use the information below:

    1. Recipe name = #{@recipe.name}
    2. Number of servings = #{@recipe.portions}
    3. List of ingredients = #{ingredients_json}
    4. Preparation steps = #{@recipe.description}
    5. Preparation time = #{@recipe.preparation_time}

    Return the data as a JSON object with the exact structure below:

    {
      "name": "Recipe name as a string (leave empty if not found). If a name is present, append 'low calories' to it."
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
    - If a piece of information is missing or not provided in the input, leave the corresponding field empty. Do not guess or make assumptions.
    - Return **only** the final JSON object.
    - Do NOT include markdown code blocks or any formatting.
    - Do not include explanations, notes, or headers.
    - Ensure the JSON is syntactically valid.
PROMPT
    @instruction =SYSTEM_PROMPT_LOWCAL
    @message = Message.new(role:"user", content: @low_cal_prompt, recipe: @recipe)
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
      Ingredient.create(name: ingredient["name"], quantity: ingredient["quantity"], unit: ingredient["unit"], recipe_id: @new_recipe.id)
    end

    if @new_recipe.update(name: name, portions: portions, preparation_time: preparation_time, description: description, url_image: @recipe.url_image, original_recipe_id: @recipe.id)
    redirect_to view_low_calories_recipe_path(@new_recipe), notice: "Low calories #{@recipe.name} 🍽️ has been succesfully created ! ✅"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def view_low_calories
    @new_recipe = Recipe.find(params[:id])
    @recipe = Recipe.find(@new_recipe.original_recipe_id)
  end

  def update_low_calories
    @recipe = Recipe.find(params[:id])
    @new_recipe = Recipe.last
    @recipe.ingredients.destroy_all
    @new_recipe.ingredients.each do  |ingredient|

      Ingredient.create(name: ingredient.name,
       quantity: ingredient.quantity,
       unit: ingredient.unit,
       recipe_id: @recipe.id
      )
    end

     if @recipe.update(name: @new_recipe.name, portions: @new_recipe.portions, preparation_time: @new_recipe.preparation_time, description: @new_recipe.description)
      @new_recipe.destroy
      redirect_to @recipe, notice: "#{@recipe.name} 🍽️ has been succesfully updated ! ✅"
    else
      render :new, status: :unprocessable_entity
    end
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
      # @recipe.ingredients.build if @recipe.ingredients.empty?
    end
    @step = params[:step]
    @recipe.save(validate: false)
    if last_step
      if @recipe.save
        respond_to do |format|
          format.html { redirect_to recipe_path(@recipe), notice: "Recipe created successfully!" }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "recipe_form_container",
              partial: "recipes/form_steps/confirmation_modal",
              locals: { recipe: @recipe }
            )
          end
        end
      else
        # render errors as usual
        render :new, status: :unprocessable_entity
      end
    else
      # Move to next step
      @step = next_step
      # Rails.logger.info "Current step: #{@step.inspect}"
      # Rails.logger.info "Next step: #{next_step.inspect}"
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

  def parse_ingredient
    text = params[:text]
    parse_prompt = <<~PROMPT
      Extract the ingredient information from the following text and return a JSON object with keys: "name", "quantity", and "unit".
      - "name" is the ingredient name as a string (with normal capitalization).
      - "quantity" is the numeric quantity as a float number.
      - "unit" is the unit of measurement as a string (e.g., g, ml, tbsp, etc.).
      If any information is missing, leave it as an empty string.

      Example input: "150g of white flour"
      Expected output:
      {
        "name": "White flour",
        "quantity": "150",
        "unit": "g"
      }

      Now parse this ingredient text: #{text}
    PROMPT
    chat = RubyLLM.chat
    response = chat.ask(parse_prompt)
    ingredient = response.content
    # ingredient = { name: "flour", quantity: "150", unit: "g" }
    render json: ingredient
  end

  def generate_img
    @recipe = Recipe.find(params[:id])
    ingredients = []
    @recipe.ingredients.each do |ingredient|
      ingredients << ingredient.name
    end
    ingredients_list = ingredients.join(', ')
    description = @recipe.description.join(' ')
    prompt_text = <<~PROMPT
      You are a professional chef and food stylist tasked with creating a high-quality, realistic image of a recipe for use in a culinary blog.

        - Recipe Name: #{@recipe.name}
        - Number of Servings: #{@recipe.portions}
        - Ingredients: #{ingredients_list}
        - Instruction of the recipe: #{description}

      Create an image that captures the finished dish alone, styled naturally and beautifully. The image should resemble typical recipe photos found on food blogs, characterized by:

      - A clean, minimalist composition focusing solely on the plated dish.
      - A simple, uncluttered table with only one or two subtle props very close to the dish—like a single fork or a small pinch of spices—used sparingly and only if they enhance the composition without drawing attention away from the food.
      - No text, logos, or distracting elements in the frame.
      - A neutral or softly textured background (wood, linen, or rustic) that enhances the dish without overpowering it.
      - Soft, natural lighting emphasizing the colors, textures, and freshness of the food.
      - Artistic but subtle presentation to make the dish look appetizing and authentic.

      The final image should be visually inviting, professional, and suitable for publication in a high-quality food blog or magazine.
    PROMPT

    image = RubyLLM.paint(prompt_text, model: "dall-e-3", size: "1792x1024")
    image_url = image&.url
    uploaded_image = Cloudinary::Uploader.upload(image_url)
    image_url_secured = uploaded_image["secure_url"]
    Rails.logger.info("Generated image: #{image.inspect}")
    Rails.logger.info("Image URL: #{image_url}")
    if image_url.present?
      render json: { url_image: image_url_secured }
    else
      render json: { error: "Image generation failed" }, status: :unprocessable_entity
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
      redirect_to edit_recipe_path(@recipe)
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
      redirect_to edit_recipe_path(@recipe)
   else
     render :new, status: :unprocessable_entity
   end
  end

  def edit
    @recipe = Recipe.find(params[:id])
  end

  def update
    @recipe = Recipe.find(params[:id])
    if @recipe.update(recipe_params)
      redirect_to @recipe, notice: "Recipe updated successfully"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @recipe = Recipe.find(params[:id])

    if @recipe.destroy
      notice_message = "#{@recipe.name} was successfully destroyed"

      if @recipe.original_recipe_id.present?
        redirect_to recipe_path(@recipe.original_recipe_id), notice: notice_message
      else
        redirect_to recipes_path, notice: notice_message
      end
    else
      render :new, status: :unprocessable_entity
    end
  end

  def discard
    @recipe = Recipe.find(params[:id])
    @recipe.destroy if @recipe.persisted?
    redirect_to root_path
  end

  def test
  end

  def toggle_favorite
    @recipe = Recipe.find(params[:id])
    favorites_collection = Collection.find_by(name: 'Favorites')

    if favorites_collection.recipes.include?(@recipe)
      favorites_collection.recipes.delete(@recipe)
      favorited = false
    else
      favorites_collection.recipes << @recipe
      favorited = true
    end

    render json: { favorited: favorited }
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

  def previous_step
    current_index = STEPS.index(@step)
    return STEPS.first if current_index.nil? || current_index.zero?

    STEPS[current_index - 1]
  end
  helper_method :previous_step

  def url_params
    params.require(:url_form).permit(:url)
  end
end
