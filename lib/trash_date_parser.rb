require "i18n"
require_relative "schedule"

class TrashDateParser
  attr_reader :data, :last_updated_at

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
    @schedules_data = data.fetch("schedules")
    @trash_types = data.fetch("scheduleDescription")
    @last_updated_at = data.fetch("changeDate")
  end

  def trash_types
    @trash_types ||= schedules.map(&:trash_type).uniq
  end

  def schedules
    @schedules ||= @schedules_data.map do |schedule_data|
      schedule = Schedule.new(schedule_data, @trash_types)
      if schedule.trash_type == "Terminy płatności"
        nil
      else
        schedule
      end
    end.compact
  end
end
