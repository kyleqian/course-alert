class MainMailer < ApplicationMailer
  def send_confirm(user)
    @user = user
    subject = @user.subscribed ? "Please confirm your updated settings" : "Please confirm your subscription" 
    mail(
          to: @user.email,
          subject: subject
        )
  end

  def send_update(user, user_diff, start_date, end_date)
    @user = user
    @user_diff = user_diff
    @start_date = start_date
    @end_date = end_date
    mail(
          to: @user.email,
          subject: 'You have new courses!'
        )
  end
end
