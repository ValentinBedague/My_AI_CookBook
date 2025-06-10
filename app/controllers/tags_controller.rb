class TagsController < ApplicationController

  def new
    @tag = Tag.new
    @collection = Collection.find(params[:collection_id])
  end
  def create
    @tag = Tag.new(tag_params)
    @collection = Collection.find(params[:collection_id])
    @tag.collection_id = @collection.id

    if @tag.save
      redirect_to @collection, notice: "#{Recipe.find(@tag.recipe_id).name} was succesfully added to #{@collection.name}."

    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @tag = Tag.find(params[:id])
    recipe_name = @tag.recipe.name
    @collection = @tag.collection

    if @tag.destroy
      redirect_to @collection, notice: "#{recipe_name} was succesfully remove from #{@collection}"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def tag_params
    params.require(:tag).permit(:collection_id, :recipe_id)
  end
end
