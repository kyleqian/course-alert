class UsersController < ApplicationController
  def home
    @user = User.new
  end

  def login
    # param passed from frontend
    @user = User.find_by(email: params[:email])
    # TODO: update this to not use defaults
    load_departments = (@user && @user.subject_settings != '[]') ? JSON.parse(@user.subject_settings) : UrlHelper.get_default_departments
    render json: load_departments.to_json
  end

  def submit
    # param passed from form
    @user = User.find_by(email: user_params[:email])
    if @user
      @user.pending_subject_settings = user_params[:pending_subject_settings]
    else
      @user = User.new(user_params)
    end

    # ERROR: if invalid
    if @user.valid?
      @user.save!
      MainMailer.send_confirm(@user).deliver_now
      redirect_to controller: :users, action: :confirmation, pid: @user.public_id
    end
  end

  def confirmation
    # ERROR: if no pid or invalid
    @user = User.find_by(public_id: params[:pid])
  end

  def update
    # apply new settings and set verify and subscribe to true
    @user = User.find_by(public_id: params[:pid])

    # ERROR: if no user or invalid user
    if @user
      if @user.pending_subject_settings != '[]'
        @user.subject_settings = @user.pending_subject_settings
        @user.pending_subject_settings = '[]'
      end
      @user.verified = true
      @user.subscribed = true
      if @user.valid?
        @user.save!
      end
    end
  end

  def unsubscribe
    # ERROR: if no pid or invalid
    @user = User.find_by(public_id: params[:pid])

    # ERROR: if no user or invalid user
    if @user
      @user.pending_subject_settings = '[]'
      @user.subscribed = false
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
