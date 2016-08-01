require 'net/http'
require 'open-uri'
require 'json'
require 'time'

class SubjectScraper
  def self.main

    listing = Nokogiri::HTML(open("https://explorecourses.stanford.edu/browse")).at_css('.departmentsContainer').children

    parsed_listing = []
    listing.each do |l|
      if l.name == 'h2'
        parsed_listing << {school: l.text.strip, departments: []}
      elsif l.name == 'ul'
        l.css('li').each do |d|
          d_match = /([^\(\)]+) \(([^\(\)]+)\)/.match(d.text.strip)
          if d_match
            getting_col = l.attribute('title').text.split(' - ')
            col = getting_col.length > 1 ? getting_col[1].split[1].to_i : 1
            d_object = {name: d_match[1], code: d_match[2], col: col, default: true}
            parsed_listing[-1][:departments] << d_object
          end
        end
      end
    end

    # TODO: I'm currently manually deleting some of the last elements
    # TODO: Also manually turning default courses on and off

    filename = "departments~#{Time.now.getlocal('-08:00').iso8601.split('.')[0].gsub(':', '-')}"
    File.open("#{filename}.json", "w") do |f|
      f.write(JSON.pretty_generate(parsed_listing))
    end
  end
end