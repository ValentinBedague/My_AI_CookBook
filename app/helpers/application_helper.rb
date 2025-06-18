module ApplicationHelper
  def user_avatar(user, size = :medium)
    if user&.photo&.attached?
      case size
      when :small
        image_tag user.photo.variant(resize_to_limit: [40, 40]),
                  class: "avatar avatar-small",
                  alt: "Photo de profil"
      when :medium
        image_tag user.photo.variant(resize_to_limit: [80, 80]),
                  class: "avatar avatar-medium",
                  alt: "Photo de profil"
      when :large
        image_tag user.photo.variant(resize_to_limit: [150, 150]),
                  class: "avatar avatar-large",
                  alt: "Photo de profil"
      end
    else
      # Avatar par défaut
      content_tag :div, user&.email&.first&.upcase || "?",
                  class: "avatar avatar-#{size} avatar-default"
    end
  end

  def display_number(num)
    return "" if num.nil?
    (num % 1).zero? ? num.to_i : num
  end

  def favorite?(recipe)
    Collection.find_by(name: 'Favorites')&.recipes&.include?(recipe)
  end
end
