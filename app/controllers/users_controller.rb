class UsersController < ApplicationController
  def home
    @user = User.new
  end

  def submit
    @user = User.new(user_params)
    puts @user.inspect
  end

  def login
    
  end

  private

  def user_params
    params.require(:user).permit(:email, subject_settings: [])
  end
end
