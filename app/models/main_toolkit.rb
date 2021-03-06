require 'net/http'
require 'dropbox_api'
require 'set'
require 'time'
require 'json'

class MainToolkit
  include UrlHelper

  # Enumerates quarters
  QUARTERS_HASH = {
    "AUTUMN" => 1,
    "FALL" => 1,
    "WINTER" => 2,
    "SPRING" => 3,
    "SUMMER" => 4
  }.freeze

  def initialize
    @dp_client = DropboxApi::Client.new(Figaro.env.dp_key)
  end

  # Retrieves lastest diff from Dropbox (stored as JSON)
  # 'daily_diff' determines whether to retrieve the daily diff or the weekly diff
  # Returns a hash of start/end dates, and the diff in hash form
  def get_latest_diff(daily_diff=false)
    path = daily_diff ? '/diffs/daily_diffs' : '/diffs'
    all_diffs = @dp_client.list_folder(path) # Everything gets put here
    has_more = all_diffs.has_more?
    prev_cursor = all_diffs.cursor
    all_diffs = all_diffs.entries.map { |x| x.to_hash }
    while has_more
      more_diffs = @dp_client.list_folder_continue(prev_cursor)
      all_diffs.concat(more_diffs.entries.map { |x| x.to_hash })
      has_more = more_diffs.has_more?
      prev_cursor = more_diffs.cursor
    end

    all_diffs = all_diffs.select { |x| x['.tag'] == 'file' }.sort_by! { |x| Time.parse(x['client_modified']) }.reverse!

    raise "Need at least 1 diff!" unless all_diffs.length > 0

    latest_diff_path = all_diffs[0]['path_display']
    start_date = latest_diff_path.split("/")[-1].split(".")[0].split('~')[2].split('T')[0]
    end_date = latest_diff_path.split("/")[-1].split(".")[0].split('~')[4].split('T')[0]

    latest_diff_json = ''
    @dp_client.download(latest_diff_path) { |chunk| latest_diff_json << chunk }
    return {
      start_date: Date.parse(start_date).strftime("%-m/%-d/%Y"),
      end_date: Date.parse(end_date).strftime("%-m/%-d/%Y"),
      latest_diff: JSON.parse(latest_diff_json)
    }
  end

  # Saves latest ExploreCourses XML into Dropbox as-is
  def download_latest_xml
    uri = URI(UrlHelper.get_url)

    puts "Downloading XML..."
    xml_file = Net::HTTP.get(uri)

    puts "Writing to Dropbox..."
    filename = "courses~#{Time.now.getlocal('-08:00').iso8601.split('.')[0].gsub(':', '-')}"
    @dp_client.upload("/xmls/#{filename}.xml", xml_file)
    @dp_client.upload("/xmls/weekly_xmls/#{filename}.xml", xml_file) if Time.now.sunday?
    puts "Done writing!"
  end

  # Creates a JSON of diffs with two specifed XMLs, and saves result to Dropbox
  # No XMLs given runs it on the two latest XMLs (daily)
  def create_diff(prev_xml_name=nil, curr_xml_name=nil)
    daily = !(prev_xml_name and curr_xml_name)

    if daily
      response = get_two_latest_xmls_from_dp()

      prev_xml = response[:prev_xml]
      prev_xml_name = response[:prev_xml_name]
      curr_xml = response[:curr_xml]
      curr_xml_name = response[:curr_xml_name]
    else

      prev_xml = ''
      curr_xml = ''
      @dp_client.download("/xmls/#{prev_xml_name}.xml") { |chunk| prev_xml << chunk }
      @dp_client.download("/xmls/#{curr_xml_name}.xml") { |chunk| curr_xml << chunk }
    end

    puts "Parsing XMLs with Nokogiri..."
    prev_courses = Nokogiri::XML(prev_xml).css('course')
    curr_courses = Nokogiri::XML(curr_xml).css('course')
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

    puts "Writing diff to Dropbox..."
    output_filename = "diff~#{prev_xml_name}~#{curr_xml_name}"
    if daily
      output_filename = 'daily_diffs/' + output_filename
    end
    @dp_client.upload("/diffs/#{output_filename}.json", JSON.pretty_generate(new_courses))
    puts "Done generating diff!"

    if new_courses.length > 0
      return true
    else
      puts "No new courses!"
      return false
    end
  end

  def move_latest_xml_to_deleted_folder
    puts "Moving latest XML from main folder..."
    curr_xml_name = get_two_latest_xmls_from_dp()[:curr_xml_name]
    @dp_client.move_v2("/xmls/#{curr_xml_name}.xml", "/xmls/deleted_xmls/#{curr_xml_name}.xml")
    puts "Finished moving!"
  end

  # Returns hash with 2 latest XMLs and their names
  # (To be used for diff'ing)
  def get_two_latest_xmls_from_dp(weekly_xmls=false)
    puts "Getting XMLs from Dropbox..."
    path = weekly_xmls ? '/xmls/weekly_xmls' : '/xmls'

    all_xmls = @dp_client.list_folder(path) # Everything gets put here
    has_more = all_xmls.has_more?
    prev_cursor = all_xmls.cursor
    all_xmls = all_xmls.entries.map { |x| x.to_hash }
    while has_more
      more_xmls = @dp_client.list_folder_continue(prev_cursor)
      all_xmls.concat(more_xmls.entries.map { |x| x.to_hash })
      has_more = more_xmls.has_more?
      prev_cursor = more_xmls.cursor
    end

    all_xmls = all_xmls.select { |x| x['.tag'] == 'file' }.sort_by! { |x| Time.parse(x['client_modified']) }.reverse!

    raise "Need at least 2 XMLs!" unless all_xmls.length >= 2

    curr_xml_path = all_xmls[0]['path_display']
    prev_xml_path = all_xmls[1]['path_display']

    curr_xml = ''
    prev_xml = ''
    @dp_client.download(curr_xml_path) { |chunk| curr_xml << chunk }
    @dp_client.download(prev_xml_path) { |chunk| prev_xml << chunk }

    return {
      curr_xml_name: curr_xml_path.split("/")[-1].split(".")[0],
      curr_xml: curr_xml,
      prev_xml_name: prev_xml_path.split("/")[-1].split(".")[0],
      prev_xml: prev_xml
    }
  end


  ##############################
  private
  ##############################


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
    parsed_course[:gers] = gers.empty? ? [] : gers.split(', ')

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