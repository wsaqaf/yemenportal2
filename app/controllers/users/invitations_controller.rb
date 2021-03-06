class Users::InvitationsController < Devise::InvitationsController
  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:invite, keys: [:email])
  end

  def after_invite_path_for(_current_inviter, _resource = nil)
    request.referrer || users_path
  end
end
