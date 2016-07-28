class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception

  protected

  def admin?
    false
  end

  def authorize
    unless admin?
      redirect_to root_path
      false
    end
  end
end
