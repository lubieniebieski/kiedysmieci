require "json"
require "i18n"

class TrashDateParser
  attr_reader :data
  def initialize(data)
    @data = parse_data(data)
  end

  def trash_days
    years.map do |year|
      year.months.map do |month|
        month.days
      end
    end.flatten.group_by { |d| d.date }
  end

  def next_trash_day(position = 0)
    trash_days.keys.sort.select { |d| d >= Date.today }[position]
  end

  def next_trash_day_types(position = 0)
    trash_days[next_trash_day(position)].map(&:trash_type).uniq.map do |type|
      I18n.t("trash_types.#{type}")
    end.join(", ")
  end

  def days_till_next_trash_day
    (next_trash_day - Date.today).to_i
  end

  def years
    @data.map do |year, year_data|
      Year.new(year, year_data)
    end
  end

  private

  def parse_data(data)
    JSON.parse(data)
  end

  class Year
    def initialize(year, year_data)
      @year = year.to_i
      @year_data = year_data
    end

    def months
      @year_data.map do |month, month_data|
        Month.new(@year, month.to_i, month_data)
      end
    end
  end

  class Month
    def initialize(year, month, month_data)
      @year = year
      @month = month
      @month_data = month_data
    end

    def days
      @month_data.map do |trash_type, days|
        days.map do |day|
          date = Date.new(@year, @month, day.to_i)
          Day.new(date, trash_type)
        end
      end.flatten
    end
  end

  class Day
    attr_reader :trash_type, :date

    def initialize(date, trash_type)
      @date = date
      @trash_type = trash_type
    end
  end
end
