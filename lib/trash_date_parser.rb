require "json"
require "i18n"
require_relative "schedule"

class TrashDateParser
  attr_reader :data

  def initialize(data)
    parse_data!(data)
  end

  def trash_days
    schedules.map { |s| s.dates }.flatten.uniq.sort
  end

  def next_trash_day(position = 0)
    trash_days.select { |d| d >= Date.today }[position]
  end

  def next_trash_day_types(position = 0)
    schedules.select { |s| s.dates.include?(next_trash_day(position)) }.map(&:trash_type).uniq.join(", ")
  end

  def days_till_next_trash_day
    (next_trash_day - Date.today).to_i
  end

  private

  def parse_data!(data)
    data = JSON.parse(data)
    @schedules_data = data["schedules"]
  end

  def schedules
    @schedules ||= @schedules_data.map do |schedule_data|
      Schedule.new(schedule_data)
    end
  end
end
