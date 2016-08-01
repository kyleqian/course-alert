namespace :ec do
  task :download => :environment do
    toolkit = MainToolkit.new
    toolkit.download_latest_xml()
  end

  task :diff => :environment do
    toolkit = MainToolkit.new
    toolkit.create_latest_diff()
  end

  task :dd => :environment do
    toolkit = MainToolkit.new
    toolkit.download_latest_xml()
    has_new_courses = toolkit.create_latest_diff()
    toolkit.move_latest_xml_to_deleted_folder if has_new_courses == false
  end

  task :send_all => :environment do
    User.send_all()
  end

  task :send_test => :environment do
    User.send_test()
  end
end
