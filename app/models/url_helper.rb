require 'json'

module UrlHelper
  ALLOWED_COMPONENTS = [
    "LEC",
    "SEM",
    "DIS",
    "LAB",
    "LBS",
    "ACT",
    "CAS",
    "COL",
    "WKS",
    # "INS",
    "IDS",
    "ISF",
    "ISS",
    # "ITR",
    "API",
    "LNG",
    "PRA",
    "PRC",
    # "RES",
    # "SCS",
    # "T/D"
  ]
  ALLOWED_UNITS = [
    "1",
    "2",
    "3",
    "4",
    "5",
    "gt5"
  ]
  ALLOWED_TERMS = [
    "Autumn",
    "Winter",
    "Spring",
    # "Summer"
  ]
  ACADEMIC_YEAR = "20162017"
  QUERY = "all+courses"

  def self.get_departments
    JSON.parse(File.read('app/models/departments~2016-07-29T11-29-17-07-00.json'))
  end

  # No longer used
  def self.get_default_departments
    default_departments = []
    self.get_departments.each do |school|
      school['departments'].each do |d|
        default_departments << d['code'] if d['default']
      end
    end
    return default_departments
  end

  def self.get_url
    url = "https://explorecourses.stanford.edu/search?q=#{QUERY}&view=xml&academicYear=#{ACADEMIC_YEAR}&filter-coursestatus-Active=on"
    ALLOWED_COMPONENTS.each { |c| url += "&filter-component-#{c}=on" }
    ALLOWED_TERMS.each { |t| url += "&filter-term-#{t}=on" }
    return url
  end

  def self.urlMaker
    # url += "&q=%s" % query
    # url += "&descriptions=on"
    # # url += "&schedules=on"
    # url += "&filter-academiclevel-UG=on"
    # for term in allowedTerms:
    #   url += "&filter-term-%s=on" % term
    # for component in allowedComponents:
    #   url += "&filter-component-%s=on" % component
    # for subject in allowedSubjects:
    #   url += "&filter-departmentcode-%s=on" % subject
    # for units in allowedUnits:
    #   url += "&filter-units-%s=on" % units

    # tiny = tinyurl.create_one(url)
    # print tiny
    # pyperclip.copy(tiny)
  end

  COURSES_TO_CHECK = [
  ]

  def self.check_courses
    results = []

    return if COURSES_TO_CHECK.empty?
    
    COURSES_TO_CHECK.each do |course_name|
      html = Net::HTTP.get(URI("https://explorecourses.stanford.edu/search?view=catalog&filter-coursestatus-Active=on&page=0&catalog=&academicYear=&q=#{course_name.delete(' ')}"))
      nodes = Nokogiri::HTML(html).css('.courseInfo')
      nodes.each do |n|
        if n.at_css('.courseNumber').text.upcase.strip == course_name.upcase + ':'
          results << n.at_css('.sectionDetails').text.strip.gsub(/[\t\n\r]+/, '')
          break
        end
      end
    end
    MainMailer.send_check_courses(results).deliver_now
  end
end

if __FILE__ == $0
  UrlHelper.check_courses
end