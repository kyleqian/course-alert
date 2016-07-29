class UsersController < ApplicationController
  def home
    @user = User.new
  end

  def login
    @user = User.find_by(email: params[:email])
    default_departments = @user ? JSON.parse(@user.subject_settings) : UrlHelper.get_default_departments
    render json: default_departments.to_json
  end

  def submit
    @user = User.new(user_params)
    if @user.valid?
      @user.save
      # if @question.email? 
      #   QuestionMailer.send_question(@question).deliver_now
      #   AdminMailer.send_question(@question).deliver_now
      # end
      # redirect_to controller: 'questions', action: 'receipt', q: @question.tracking_id
    end
  end

  def confirmation
  end

  private

  def user_params
    params[:user][:subject_settings].reject!(&:empty?)
    params.require(:user).permit(:email, subject_settings: [])
  end
end
