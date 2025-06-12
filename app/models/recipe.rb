class Recipe < ApplicationRecord
  belongs_to :user
  has_many :ingredients, dependent: :destroy

  has_many :tags
  has_many :collections, through: :tags

  has_one_attached :image
end
