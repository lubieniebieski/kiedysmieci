require "icalendar"

class CalendarGenerator
  def initialize(trash_parser)
    @trash_parser = trash_parser
  end

  def generate
    calendar = Icalendar::Calendar.new
    calendar.timezone do |t|
      t.tzid = "Europe/Warsaw"
    end
    calendar.x_wr_calname = "Wywóz śmieci Turew"
    calendar.x_wr_timezone = "Europe/Warsaw"
    calendar.x_wr_caldesc = "Harmonogram wywozu śmieci w Turwi"
    calendar.description = "Harmonogram wywozu śmieci w Turwi"
    calendar.refresh_interval = "P1W"
    calendar.url = "https://smieci.turew.pl"

    @trash_parser.trash_days.each do |trash_day|
      calendar.add_event(create_event(trash_day))
    end

    calendar.to_ical
  end

  private

  def create_event(trash_day)
    event = Icalendar::Event.new
    event.dtstart = Icalendar::Values::Date.new(trash_day.date) # Set as date only
    event.dtend = Icalendar::Values::Date.new(trash_day.date + 1) # End date is next day for all-day events
    event.summary = "Wywóz śmieci: #{trash_day}"
    event.description = trash_day.to_s + " - wywóz śmieci \nvia https://smieci.turew.pl"

    # Add alarm for 4pm the day before
    event.alarm do |a|
      a.summary = "Wywóz śmieci: #{trash_day}"
      a.trigger = "-PT8H" # 1 day before at 16:00 (4pm)
    end

    event
  end
end
