class MongoWrapper
  def initialize
    @database = Mongo::Client.new('mongodb://admin:admin@ds023455.mlab.com:23455/ecd')
  end

  # def generate_latest_diff(self):
  #   collections = sorted([c for c in self.client.ecd.collection_names() if c.startswith('courses')])

  #   if len(collections) < 2: raise IndexError("There must be at least 2 collections in the database.")

  #   prev_collection = self.client.ecd[collections[-2]]
  #   curr_collection = self.client.ecd[collections[-1]]

  #   new_courses = []
  #   count = 0
  #   for course in curr_collection.find({}, {'_id': False}):
  #     department = course['department']
  #     code = course['code']
  #     if prev_collection.find_one({'department':department, 'code': code}) == None:
  #       new_courses.append(loads(dumps(course)))
  #     count += 1
  #     print "Getting diffs: %s courses processed" % count
  #   print "Finished generating diffs!"
  #   return (prev_collection.name, curr_collection.name, new_courses)

  def insert_objects(collection_name, o)
    collection = @database[collection_name]
    puts "Inserting objects into MongoDB..."
    result = collection.insert_many(o)
    puts "Inserted #{result.inserted_count} objects!"
  end
end