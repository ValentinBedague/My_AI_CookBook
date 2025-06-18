class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  has_many :recipes
  has_many :collections
  has_one_attached :photo

  # Gestion des restrictions
  has_many :user_restrictions, dependent: :destroy
  has_many :restrictions, through: :user_restrictions
end
