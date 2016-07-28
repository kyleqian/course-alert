class UsersController < ApplicationController
  def home
    @user = User.new
  end

  def submit
    @user = User.new(params[:user].require(:email, :subject_settings))
    puts @user.inspect
  end

  def login
    
  end
end
