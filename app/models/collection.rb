class Collection < ApplicationRecord
  belongs_to :user

  has_many :tags, dependent: :destroy
  has_many :recipes, through: :tags
end
