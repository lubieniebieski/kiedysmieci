require "json"
require "pry"

class DataCleaner
  def initialize(file_name = "data.json")
    @file_name = file_name
    @data = JSON.parse(File.read(file_name, encoding: "bom|utf-8"))
    clean!
  end

  def clean!
    ["scheduleDescription", "street", "town", "name", "id", "groupname", "groupdescription", "search"].each do |key|
      @data.delete(key)
    end
    @data["schedules"] = @data["schedules"].reject { |s| s["scheduleDescriptionId"] == "54659" }
  end

  def save!
    File.write(@file_name, JSON.pretty_generate(@data))
  end
end

if ARGV[0] == "GO"
  puts "Cleaning data..."
  data_cleaner = DataCleaner.new
  data_cleaner.save!
end
