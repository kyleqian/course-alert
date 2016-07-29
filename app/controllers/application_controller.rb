class ApplicationController < ActionController::Base
  protect_from_forgery with: :null_session, if: Proc.new { |c| c.request.format == 'application/json' }

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
