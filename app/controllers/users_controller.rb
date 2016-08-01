class UsersController < ApplicationController
  def home
    @user = User.new
  end

  def login
    # Param passed from frontend JavaScript (before actually submitting)
    email = params[:email].strip
    @user = User.find_by(email: email)
    
    load_departments = @user ? JSON.parse(@user.subject_settings) : []
    render json: load_departments.to_json
  end

  def submit
    # Param passed from form
    @user = User.find_by(email: user_params[:email])
    if @user
      @user.pending_subject_settings = user_params[:pending_subject_settings]
    else
      @user = User.new(user_params)
    end

    if @user.valid?
      @user.save!
      MainMailer.send_confirm(@user).deliver_now
      redirect_to controller: :users, action: :confirmation, pid: @user.public_id
    else
      redirect_to '/error'
      return
    end
  end

  def confirmation
    unless params[:pid]
      redirect_to '/error'
      return
    end

    @user = User.find_by(public_id: params[:pid])
    unless @user
      redirect_to '/error'
      return
    end
  end

  # Applies new settings and sets :verify and :subscribe to true
  def update
    unless params[:pid]
      redirect_to '/error'
      return
    end

    @user = User.find_by(public_id: params[:pid])
    unless @user
      redirect_to '/error'
      return
    end

    if @user.pending_subject_settings != '[]'
      @user.subject_settings = @user.pending_subject_settings
      @user.pending_subject_settings = '[]'
    end
    @user.verified = true
    @user.subscribed = true

    if @user.valid?
      @user.save!
    else
      redirect_to '/error'
      return
    end
  end

  def unsubscribe
    unless params[:pid]
      redirect_to '/error'
      return
    end

    @user = User.find_by(public_id: params[:pid])
    unless @user
      redirect_to '/error'
      return
    end

    @user.pending_subject_settings = '[]'
    @user.subscribed = false
    if @user.valid?
      @user.save!
    else
      redirect_to '/error'
      return
    end
  end

  private

  def user_params
    params[:user][:pending_subject_settings].reject!(&:empty?)
    params.require(:user).permit(:email, pending_subject_settings: [])
  end
end
