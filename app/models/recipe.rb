class Recipe < ApplicationRecord
  belongs_to :user
  has_many :ingredients, dependent: :destroy

  has_many :tags
  has_many :collections, through: :tags
end
