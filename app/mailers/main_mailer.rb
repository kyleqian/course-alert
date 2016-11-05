class MainMailer < ApplicationMailer
  default from: 'CourseAlert <admin@coursealert.co>'

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

    course_count = @user_diff.length
    raise unless course_count > 0

    mail(
          to: @user.email,
          subject: "You have #{course_count} new #{course_count > 1 ? 'courses' : 'course'}!"
        )
  end

  def send_check_courses(courses, to='kylecqian@gmail.com')
    mail(
          to: to,
          subject: "Course Availabilities",
          body: courses.join("\n\n")
        )
  end

  def send_daily(diff)
    mail(
          to: 'kylecqian@gmail.com',
          subject: "Daily diff",
          body: diff
        )
  end

  def check_rate(count=0, to='kylecqian@gmail.com')
    mail(to: to, subject: "Testing #{count}", body: "Testing rate")
  end
end
