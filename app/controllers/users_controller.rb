class UsersController < ApplicationController
  def home
    @user = User.new
  end

  def login
    # param passed from frontend
    @user = User.find_by(email: params[:email])
    default_departments = (@user && @user.subject_settings != '[]') ? JSON.parse(@user.subject_settings) : UrlHelper.get_default_departments
    render json: default_departments.to_json
  end

  def submit
    # param passed from form
    @user = User.find_by(email: user_params[:email])
    status = nil
    if @user
      status = 'update'
      @user.pending_subject_settings = user_params[:pending_subject_settings]
    else
      status = 'new'
      @user = User.new(user_params)
    end

    if @user.valid?
      @user.save!
      MainMailer.send_confirm(@user, status).deliver_now
      redirect_to controller: :users, action: :confirmation, s: status
    end
  end

  def confirmation
  end

  def update
    # apply new settings and set verify and subscribe to true
    @user = User.find_by(public_id: params[:pid])
    if @user
      @user.subject_settings = @user.pending_subject_settings
      @user.verified = true
      @user.subscribed = true
      @user.pending_subject_settings = '[]'
      if @user.valid?
        @user.save!
      end
    end
  end

  private

  def user_params
    params[:user][:pending_subject_settings].reject!(&:empty?)
    params.require(:user).permit(:email, pending_subject_settings: [])
  end
end
