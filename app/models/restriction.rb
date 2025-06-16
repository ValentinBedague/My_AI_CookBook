class Restriction < ApplicationRecord
  belongs_to :user

  AVAILABLE_DIETS = [
    ['Végétarien', 'vegetarian'],
    ['Végétalien', 'vegan'],
    ['Sans gluten', 'gluten_free'],
    ['Sans lactose', 'dairy_free'],
    ['Sans noix', 'nut_free'],
    ['Halal', 'halal'],
    ['Casher', 'kosher']
  ].freeze

  # Initialiser diet comme un array vide
  def diet
    super || []
  end
end
