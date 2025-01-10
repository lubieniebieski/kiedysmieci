require "i18n"
require_relative "schedule"
require_relative "trash_day"

class TrashDateParser
  attr_reader :data, :last_updated_at

  def initialize(data)
    parse_data!(data)
  end

  def trash_days
    dates_with_types = {}

    schedules.each do |schedule|
      schedule.dates.each do |date|
        dates_with_types[date] ||= []
        dates_with_types[date] << schedule.trash_type
      end
    end

    dates_with_types.map { |date, types| TrashDay.new(date, types) }
      .sort_by(&:date)
  end

  def next_trash_day(position = 0)
    trash_days.select { |td| td.date >= Date.today }[position]
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
