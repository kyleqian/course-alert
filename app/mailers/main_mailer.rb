class MainMailer < ApplicationMailer
  def send_confirm(user, status)
    @user = user
    @status = status
    subject = status == 'new' ? "Confirm your subscription" : "Confirming your update"
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
        subject: 'New courses!'
     )
  end
end