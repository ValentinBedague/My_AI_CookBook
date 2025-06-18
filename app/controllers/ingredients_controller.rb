class IngredientsController < ApplicationController
  SYSTEM_PROMPT = "You are a Cooking Assistant. Your outputs need to be realistic and preserve qualitative recipes. Your answers need to respect the language of the user's recipe. Based on the following recipe:\n\n"

def view_swap_ingredients
    @recipe = Recipe.find(params[:recipe_id])
  end

  def choice_swap_ingredients
    @recipe = Recipe.find(params[:recipe_id])
    @ingredients = @recipe.ingredients
  end

  def swap_ingredients
    @recipe = Recipe.find(params[:recipe_id])

    @why = params[:diet_explanation]
    @replaced_ingredients_ids = params[:ingredient_ids]
    @replaced_ingredients = Ingredient.where(id: @replaced_ingredients_ids).pluck(:name).join(", ")
    if params[:use_restrictions] == "1"
       @personal_diet = User.find(@recipe.user_id).restrictions.pluck(:name).join(", ")
    else
      @personal_diet = "I have no personal diet"
    end

    @swap_ingredients_prompt = <<~PROMPT
    You will receive information about a recipe and a list of ingredients to replace.

    Can you replace the following ingredient(s): #{@replaced_ingredients}?

    Reason for replacement: #{@why}.

    Please also consider my personal diet restrictions/preferences: #{@personal_diet}.

    Your tasks:

    1. Keep the original list of ingredients except the #{@replaced_ingredients}, which you must replace with suitable alternatives that respect the diet and reason given.
    2. Update the preparation instructions accordingly to reflect the ingredient changes.
    3. Adjust the preparation time if necessary.

    Return the data as a JSON object with this exact structure:

    {
      "preparation_time": "Preparation time as an integer (in minutes, e.g., 30)",
      "description": "An array of step-by-step instructions as strings (e.g., 'Do this', 'Then do that')",
      "ingredients": {
        "ingredient1": {
          "name": "Ingredient name as a string",
          "quantity": "Quantity as a number (integer or float, e.g., 500 or 0.5)",
          "unit": "Unit as a string (leave empty if not applicable)"
        },
        "ingredient2": {
          "name": "Ingredient name as a string",
          "quantity": "Quantity as a number (integer or float, e.g., 500 or 0.5)",
          "unit": "Unit as a string (leave empty if not applicable)"
        }
        # Add as many ingredients as needed, using the same structure
      }
    }

    ⚠️ Strict instructions:
    - Do not guess or make assumptions.
    - Return **only** the final JSON object.
    - Do NOT include markdown code blocks or any formatting.
    - Do not include explanations, notes, or headers.
    - Ensure the JSON is syntactically valid.
PROMPT
      @instruction = [SYSTEM_PROMPT, set_context].compact.join("\n\n")
      @message = Message.new(role: "user", content: @swap_ingredients_prompt, recipe: @recipe)
      @chat = RubyLLM.chat
      response = @chat.with_instructions(@instruction).ask(@message.content)
      Message.create(role: "assistant", content: response.content, recipe: @recipe)
      json_response = Message.last.content
      data = JSON.parse(json_response)
      preparation_time = data["preparation_time"]
      description = data["description"]
      ingredients = data["ingredients"]


      if @recipe.update(preparation_time: preparation_time, description: description)
        @recipe.ingredients.destroy_all
        ingredients.each do |key, ingredient|
          Ingredient.create(name: ingredient["name"], quantity: ingredient["quantity"], unit: ingredient["unit"], recipe_id: @recipe.id)
        end
        redirect_to  view_swap_ingredients_recipe_ingredients_path(@recipe), notice: "#{@recipe.name} 🍽️ has been succesfully updated ! ✅"
      else
        render :new, status: :unprocessable_entity
      end
  end

  private
  # def swap_params
  #   params.require(:recipe_id).permit(:use_restriction, :ingredient_ids, :diet_explanation)
  # end

  def set_context
    @context = "Recipe name: #{@recipe.name}\n\nRecipe current portions: #{@recipe.portions}\n\nRecipe current ingredients: #{@recipe.ingredients.pluck(:name).join(", ")}\n\nRecipe current step-by-step instructions: #{@recipe.description.inspect}, Recipe Current preparation time : #{@recipe.preparation_time}"
  end
end
