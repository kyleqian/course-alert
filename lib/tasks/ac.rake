namespace :ac do

  task download: :environment do
    toolkit = MainToolkit.new
    toolkit.download_latest_xml()
  end

  task diff: :environment do
    toolkit = MainToolkit.new
    toolkit.create_diff()
  end

  # Runs daily
  # Creates daily diff and sends to email
  task dd: :environment do
    toolkit = MainToolkit.new
    toolkit.download_latest_xml()
    toolkit.create_diff()
    User.send_daily()
  end

  # Runs weekly
  # Creates weekly diff and sends to email
  task weekly_diff: :environment do
    return unless Time.now.sunday?

    toolkit = MainToolkit.new
    response = toolkit.get_two_latest_xmls_from_dp(weekly_xmls=true)
    toolkit.create_diff(response[:prev_xml_name], response[:curr_xml_name])
    User.send_test()
  end

  task send_all: :environment do
    User.send_all()
  end

  task send_test: :environment do
    User.send_test()
  end

  task check_courses: :environment do
    UrlHelper.check_courses()
  end

  task users: :environment do
    emails = User.order(id: :asc).pluck(:email)
    puts emails.join("\n")
    puts "\n#{emails.length} users"
  end

  task check_rate: :environment do
    User.count.times do |i|
      MainMailer.check_rate(i + 1).deliver_now
      sleep(10)
    end
  end
end
