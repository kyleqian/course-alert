namespace :ec do
  task :download => :environment do
    toolkit = MainToolkit.new
    toolkit.download_latest_xml()
  end

  task :diff => :environment do
    toolkit = MainToolkit.new
    toolkit.create_latest_diff()
  end

  task :all => :environment do
    toolkit = MainToolkit.new
    toolkit.download_latest_xml()
    toolkit.create_latest_diff()
  end
end
