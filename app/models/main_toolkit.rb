require 'net/http'
require 'dropbox_sdk'
require 'set'
require 'time'
require 'json'

class MainToolkit
  include UrlHelper

  QUARTERS_HASH = {
    "AUTUMN" => 1,
    "FALL" => 1,
    "WINTER" => 2,
    "SPRING" => 3,
    "SUMMER" => 4
  }.freeze

  def initialize
    @dp_client = DropboxClient.new(Figaro.env.dp_key)
  end

  def get_latest_diff
    all_diffs = @dp_client.metadata('/diffs')['contents'].sort_by! { |x| Time.parse(x['client_mtime']) }.reverse!

    raise "Need at least 1 diff!" unless all_diffs.length >= 1

    latest_diff_path = all_diffs[0]['path']
    return {start_date: latest_diff_path.split("/")[-1].split(".")[0].split('~')[2].split('T')[0], end_date: latest_diff_path.split("/")[-1].split(".")[0].split('~')[4].split('T')[0], latest_diff: JSON.parse(@dp_client.get_file(latest_diff_path))}
  end

  # Saves latest EC XML into Dropbox
  def download_latest_xml
    uri = URI(UrlHelper.get_url)

    puts "Getting request..."
    xml_file = Net::HTTP.get(uri)

    puts "Writing to Dropbox..."
    filename = "courses~#{Time.now.iso8601.split('.')[0].gsub(':', '-')}"
    @dp_client.put_file("xmls/#{filename}.xml", xml_file)
    puts "Done writing!"
  end

  # Creates a JSON of diffs with the two latest XMLs, and saves result to Dropbox
  def create_latest_diff
    response = get_two_latest_xmls_from_dp()

    puts "Parsing XMLs with Nokogiri..."
    curr_courses = Nokogiri::XML(response[:curr_xml]).css('course')
    prev_courses = Nokogiri::XML(response[:prev_xml]).css('course')
    puts "Prev courses: #{prev_courses.length}"
    puts "Curr courses: #{curr_courses.length}"

    # Collect all previous course names into a Set
    prev_courses_names = Set.new
    prev_courses.each do |c|
      subject = (c > 'subject').text.upcase.strip
      code = (c > 'code').text.upcase.strip
      prev_courses_names.add("#{subject}#{code}")
    end

    # Collect courses that don't show up in the prev XML
    new_courses = []
    puts "Comparing courses..."
    curr_courses.each do |c|
      subject = (c > 'subject').text.upcase.strip
      code = (c > 'code').text.upcase.strip
      if !prev_courses_names.include? "#{subject}#{code}"
        new_courses.append(parse_course(c))
      end
    end

    if new_courses.length > 0
      puts "Writing diff to Dropbox..."
      output_filename = "diff~#{response[:prev_xml_name]}~#{response[:curr_xml_name]}"
      @dp_client.put_file("diffs/#{output_filename}.json", JSON.pretty_generate(new_courses))
      puts "Done generating diff!"
      return true
    else
      puts "No new courses!"
      return false
    end
  end

  def move_latest_xml_to_deleted_folder
    puts "Moving latest XML from main folder..."
    curr_xml_name = get_two_latest_xmls_from_dp()[:curr_xml_name]
    @dp_client.file_move("xmls/#{curr_xml_name}.xml", "/xmls/deleted_xmls/#{curr_xml_name}.xml")
    puts "Finished moving!"
  end

  ##############################
  private
  ##############################

  # returns hash with 2 latest XMLs and their names
  def get_two_latest_xmls_from_dp
    puts "Getting XMLs from Dropbox..."
    all_xmls = @dp_client.metadata('/xmls')['contents'].select { |x| !x['is_dir'] }.sort_by! { |x| Time.parse(x['client_mtime']) }.reverse!

    raise "Need at least 2 XMLs!" unless all_xmls.length >= 2

    curr_xml_path = all_xmls[0]['path']
    prev_xml_path = all_xmls[1]['path']

    return {curr_xml_name: curr_xml_path.split("/")[-1].split(".")[0], curr_xml: @dp_client.get_file(curr_xml_path), prev_xml_name: prev_xml_path.split("/")[-1].split(".")[0], prev_xml: @dp_client.get_file(prev_xml_path)}
  end

  # Argument: Nokogiri-parsed <course> Node
  # Return: <course> parsed as a hash
  # TODO: a method for each?
  def parse_course(c)
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
end