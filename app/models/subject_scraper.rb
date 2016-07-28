require 'net/http'
require 'Nokogiri'
require 'open-uri'
require 'json'
require 'time'

listing = Nokogiri::HTML(open("https://explorecourses.stanford.edu/browse")).at_css('.departmentsContainer').children

parsed_listing = []
listing.each do |l|
  if l.name == 'h2'
    parsed_listing << {school: l.text.strip, departments: []}
  elsif l.name == 'ul'
    l.css('li').each do |d|
      d_match = /([^\(\)]+) \(([^\(\)]+)\)/.match(d.text.strip)
      if d_match
        d_object = {name: d_match[1], code: d_match[2], default: true}
        parsed_listing[-1][:departments] << d_object
      end
    end
  end
end

filename = "departments~#{Time.now.iso8601.split('.')[0].gsub(':', '-')}"
File.open("#{filename}.json", "w") do |f|
  f.write(JSON.pretty_generate(parsed_listing))
end