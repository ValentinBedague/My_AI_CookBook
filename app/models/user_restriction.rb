class UserRestriction < ApplicationRecord
  belongs_to :user
  belongs_to :restriction
  validates :user_id, uniqueness: { scope: :restriction_id }
end
