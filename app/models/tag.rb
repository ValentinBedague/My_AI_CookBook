class Tag < ApplicationRecord
  belongs_to :collection
  belongs_to :recipe
end
