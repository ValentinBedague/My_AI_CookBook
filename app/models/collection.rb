class Collection < ApplicationRecord
  has_many :tags, dependent: :destroy
  has_many :recipes, through: :tags
end
