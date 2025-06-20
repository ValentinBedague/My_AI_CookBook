class Recipe < ApplicationRecord
  belongs_to :user
  has_many :ingredients, dependent: :destroy

  has_many :tags, dependent: :destroy
  has_many :collections, through: :tags
  has_many :messages, dependent: :destroy

  has_one_attached :image

  accepts_nested_attributes_for :ingredients, allow_destroy: true
end
