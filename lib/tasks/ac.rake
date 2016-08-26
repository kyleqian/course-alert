namespace :ac do
  task download: :environment do
    toolkit = MainToolkit.new
    toolkit.download_latest_xml()
  end

  task diff: :environment do
    toolkit = MainToolkit.new
    toolkit.create_diff()
  end

  task dd: :environment do
    toolkit = MainToolkit.new
    toolkit.download_latest_xml()
    toolkit.create_diff()
  end

  task send_all: :environment do
    User.send_all()
  end

  task send_test: :environment do
    User.send_test()
  end

  task send_scheduled_test: :environment do
    User.send_test() if Time.now.sunday?
  end

  task check_courses: :environment do
    UrlHelper.check_courses()
  end

  task users: :environment do
    emails = User.pluck(:email)
    puts emails.join("\n")
    puts "\n#{emails.length} users"
  end

  task check_rate: :environment do
    User.count.times do |i|
      MainMailer.check_rate(i + 1).deliver_now
      sleep(30)
    end
  end
end
