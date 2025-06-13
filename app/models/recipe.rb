class Recipe < ApplicationRecord
  belongs_to :user
  has_many :ingredients, dependent: :destroy

  has_many :tags
  has_many :collections, through: :tags

  accepts_nested_attributes_for :ingredients, allow_destroy: true
end
