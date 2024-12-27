require "net/http"
require "json"
require "date"

class Downloader
  BASE_URL = "https://pluginssl.ecoharmonogram.pl/api/v1/plugin/v1"

  def initialize
    @community_id = ENV.fetch("COMMUNITY_ID")
    @street_name = ENV.fetch("STREET_NAME")
    @town_id = ENV.fetch("TOWN_ID")
  end

  def fetch_schedule_periods
    uri = URI("#{BASE_URL}/schedulePeriodsWithDataForCommunity")
    response = Net::HTTP.post(uri, "communityId=#{@community_id}")
    parse_json(response.body).fetch("schedulePeriods")
  end

  def fetch_streets(period_id)
    uri = URI("#{BASE_URL}/streets")
    params = {
      streetName: @street_name,
      townId: @town_id,
      schedulePeriodId: period_id
    }
    response = Net::HTTP.post(uri, URI.encode_www_form(params))
    parse_json(response.body).fetch("streets")
  end

  def fetch_schedules(street_id)
    uri = URI("#{BASE_URL}/schedules")
    params = {
      streetId: street_id
    }
    response = Net::HTTP.post(uri, URI.encode_www_form(params))
    parse_json(response.body)
  end

  def download_all
    result = {
      "schedules" => [],
      "scheduleDescription" => [],
      "changeDate" => DateTime.parse("2000-01-01")
    }

    periods = fetch_schedule_periods
    periods.each do |period|
      streets = fetch_streets(period.fetch("id"))
      streets.each do |street|
        schedule_data = fetch_schedules(street.fetch("id"))
        result["schedules"].concat(schedule_data.fetch("schedules", []))
        result["scheduleDescription"].concat(schedule_data.fetch("scheduleDescription", []))
        change_date = DateTime.parse(schedule_data.fetch("schedulePeriod").fetch("changeDate"))
        result["changeDate"] = change_date if change_date > result["changeDate"]
      end
    end

    result
  end

  def self.download_all
    new.download_all
  end

  private

  def parse_json(response_body)
    clean_response = response_body.force_encoding("UTF-8").sub("\xEF\xBB\xBF", "")
    JSON.parse(clean_response)
  end
end

# Optionally save the result
# result = Downloader.new.download_all
# File.write('schedules.json', JSON.pretty_generate(result))
