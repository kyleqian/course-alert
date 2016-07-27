class AdminController < ApplicationController
  before_action :authorize

  def admin
  end

  def run
    toolkit = MainToolkit.new
    toolkit.download_latest_xml()
    puts '======================'
    toolkit.create_latest_diff()
  end
end
