class CollectionsController < ApplicationController
  STEPS = %w[name image]

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
    if params[:return_to].present?
      @return_to = CGI.unescape(params[:return_to])
    else
      @return_to = collections_path
    end
  end

  def new
    @collection = Collection.new
    @step = STEPS.first
  end

  def create
    if params[:id]
      @collection = Collection.find(params[:id])
      @collection.assign_attributes(collection_params)
    else
      @collection = Collection.new(collection_params)
      @collection.user = current_user
    end
    @step = params[:step]
    @collection.save(validate: false)
    if last_step
      if @collection.save
        respond_to do |format|
          format.html { redirect_to @collection, notice: "Collection created successfully!" }
          format.turbo_stream do
            render turbo_stream: turbo_stream.replace(
              "collection_form_container",
              partial: "collections/form_steps/confirmation_modal",
              locals: { collection: @collection }
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
            "collection_form_container",
            partial: "collections/form_steps/#{@step}",
            locals: { collection: @collection }
          )
        end
      end
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

  def discard
    @collection = Collection.find(params[:id])
    @collection.destroy if @collection.persisted?
    redirect_to collections_path
  end

  def toggle_favorite
    @collection = Collection.find(params[:id])
    @collection.update(isfavorite: !@collection.isfavorite)
    render json: { favorited: @collection.isfavorite }
  end

  private

  def collection_params
    params.require(:collection).permit(:name, :url_image)
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
end
