namespace :ec do
  task :download => :environment do
    toolkit = MainToolkit.new
    toolkit.download_latest_xml()
  end

  task :diff => :environment do
    toolkit = MainToolkit.new
    toolkit.create_latest_diff()
  end

  task :download_diff => :environment do
    toolkit = MainToolkit.new
    toolkit.download_latest_xml()
    toolkit.create_latest_diff()
  end

  task :send_all => :environment do
    User.send_all()
  end

  task :send_test => :environment do
    User.send_test()
  end
end
