class CollectionsController < ApplicationController

  def index

    if params[:query].present?
      terms = params[:query].split
      @collections = Collection.joins(tags: :recipe).distinct

      terms.each do |term|
        @collections = @collections.where(
          "collections.name ILIKE :term OR recipes.name ILIKE :term",
          term: "%#{term}%"
          )
      end

      @favorites = nil
    else
      @collections = Collection.all
      @favorites = Collection.find_by(name: "Favorites")
    end
  end

  def show
    @collection = Collection.find(params[:id])
    @tags = @collection.tags
  end

  def new
    @collection = Collection.new
  end

  def create
    @collection = Collection.new(collection_params)
    if @collection.url_image == ""
      @collection.url_image = "https://www.ensto-ebs.fr/modules/custom/legrand_ecat/assets/img/no-image.png"
    end
    if @collection.save
      redirect_to @collection, notice: "#{@collection.name} collection was successfully created!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def destroy
    @collection = Collection.find(params[:id])

    if @collection.destroy
      redirect_to collections_path, notice: "#{@collection.name} was succesfully destroyed"
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :url_image)
  end

end
