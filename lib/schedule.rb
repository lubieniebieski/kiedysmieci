require "date"
class Schedule
  attr_reader :id, :month, :days, :year, :schedule_description_id
  attr_accessor :schedule_description

  def initialize(data, trash_types)
    @id = data["id"]
    @month = data["month"].to_i
    @days = data["days"].split(";").map(&:to_i)
    @year = data["year"]
    @trash_types = trash_types
    @schedule_description_id = data["scheduleDescriptionId"]
  end

  def dates
    @dates ||= days.map do |day|
      Date.new(year.to_i, month, day)
    rescue Date::Error
      nil
    end.compact
  end

  def trash_type
    name = @trash_types.find { |type| type["id"] == schedule_description_id }["name"]
    name.downcase.capitalize
  end
end
