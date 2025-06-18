class ApplicationController < ActionController::Base
  before_action :authenticate_user!, except: [:home_visitor]
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    # Paramètres pour l'inscription
    devise_parameter_sanitizer.permit(:sign_up, keys: [:photo])
    # Paramètres pour la mise à jour du compte
    devise_parameter_sanitizer.permit(:account_update, keys: [:photo])
  end
end
