require "date"
class Schedule
  attr_reader :id, :month, :days, :year, :schedule_description_id
  attr_accessor :schedule_description

  def initialize(data)
    @id = data["id"]
    @month = data["month"].to_i
    @days = data["days"].split(";").map(&:to_i)
    @year = data["year"]
    @schedule_description_id = data["scheduleDescriptionId"]
  end

  def dates
    @dates ||= days.map do |day|
      Date.new(year.to_i, month, day)
    end
  end

  def trash_type
    I18n.t("trash_types.#{schedule_description_id}")
  end
end
