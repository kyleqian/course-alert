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
  ACADEMIC_YEAR = "20172018"
  QUERY = "all+courses"

  def self.get_departments
    JSON.parse(File.read('app/models/department_jsons/departments~2017-06-25T21-11-45-08-00.json'))
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
    
    COURSES_TO_CHECK.each do |c|
      course_name = c.split('|')[0]
      course_term = c.split('|')[1]
      html = Net::HTTP.get(URI("https://explorecourses.stanford.edu/search?view=catalog&filter-coursestatus-Active=on&page=0&catalog=&academicYear=&q=#{course_name.delete(' ')}"))
      nodes = Nokogiri::HTML(html).css('.courseInfo')
      nodes.each do |n|
        if n.at_css('.courseNumber').text.upcase.strip == course_name + ':'
          n.css('.sectionContainer').each do |sc|
            if (sc > '.sectionContainerTerm').text.strip == course_term
              sc.css('.sectionDetails').each do |sd|
                results << sd.text.strip.gsub(/[\t\n\r]+/, '')
              end
              break
            end
          end
        end
      end
    end
    MainMailer.send_check_courses(results).deliver_now
  end
end

if __FILE__ == $0
  UrlHelper.check_courses
end