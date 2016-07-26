require 'net/http'
require 'dropbox_sdk'
require 'set'

module XmlHelper
  DP_KEY = 'Pu-hL21vvKwAAAAAAACQwGq902w2bxE3yw8TwMphQDdZK4r9_KuZS4QKwaanBI1c'
  QUARTERS_HASH = {
    "AUTUMN" => 1,
    "FALL" => 1,
    "WINTER" => 2,
    "SPRING" => 3,
    "SUMMER" => 4
  }
  private_constant :QUARTERS_HASH, :DP_KEY

  def self.get_url
    # return "https://explorecourses.stanford.edu/search?q=all+courses&view=xml&academicYear=20162017&filter-term-Autumn=on&filter-term-Winter=on&filter-term-Spring=on&filter-coursestatus-Active=on"
    return "https://explorecourses.stanford.edu/search?q=CS&view=xml&academicYear=20162017&filter-term-Autumn=on&filter-term-Winter=on&filter-term-Spring=on&filter-coursestatus-Active=on"
  end

  def self.write_to_dp(path, file)
    client = DropboxClient.new(DP_KEY)
    client.put_file(path, file)
  end

  # TODO: a method for each?
  def self.parse_course(c)
    parsed_course = {}

    year = (c > 'year').text.strip
    parsed_course[:year] = year.empty? ? nil : year

    department = (c > 'subject').text.strip
    parsed_course[:department] = department.empty? ? nil : department

    code = (c > 'code').text.strip
    parsed_course[:code] = code.empty? ? nil : code

    title = (c > 'title').text.strip
    parsed_course[:title] = title.empty? ? nil : title

    description = (c > 'description').text.strip
    parsed_course[:description] = description.empty? ? nil : description

    gers = (c > 'gers').text.strip
    parsed_course[:gers] = gers.empty? ? nil : gers

    quarters = Set.new
    sections = []

    c.css('section').each do |s|
      section = {}

      year_quarter = (s > 'term').text.strip
      if year_quarter.empty?
        year_quarter = [nil, nil]
      else
        year_quarter = year_quarter.upcase.split
        quarters.add(year_quarter[1])
      end
      section[:year] = year_quarter[0]
      section[:quarter] = year_quarter[1]

      sectionID = (s > 'classid').text.strip
      section[:sectionID] = sectionID.empty? ? nil : sectionID

      units = (s > 'units').text.strip
      section[:units] = units.empty? ? nil : units

      component = (s > 'component').text.strip
      section[:component] = component.empty? ? nil : component

      sectionID = (s > 'classId').text.strip
      section[:sectionID] = sectionID.empty? ? nil : sectionID

      instructors = (s > 'instructors').text.strip
      section[:instructors] = instructors.empty? ? nil : instructors.split(';').map! { |x| x.strip }

      notes = (s > 'notes').text.strip
      section[:notes] = notes.empty? ? nil : notes

      sections.append(section)
    end

    parsed_course[:sections] = sections
    parsed_course[:quarters] = quarters.to_a.sort_by! { |x| QUARTERS_HASH[x] }
    return parsed_course
  end

  def self.download_latest_xml(filename)
    uri = URI(self.get_url)

    puts "Getting request..."
    xml_file = Net::HTTP.get(uri)

    puts "Writing to Dropbox..."
    self.write_to_dp("XMLs/#{filename}.xml", xml_file)
    puts "Done writing!"

    # puts "Parsing with Nokogiri..."
    # soup = Nokogiri::XML(xml_file)
    # courses = soup.css('course')
    # puts "#{courses.length} courses collected"

    # parsed_courses = []
    # parsed_courses = courses.each_with_index do |c, i|
    #   parsed_courses.append(self.parse_course(c))
    #   puts "Parsing XML: #{i} objects parsed"
    # end

    # puts "Done parsing!"
    # return parsed_courses
  end
end