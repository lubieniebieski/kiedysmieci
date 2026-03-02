require "bundler/setup"
require "dotenv/load"
require "fileutils"
require "http"
require "json"
require "pry"
require "rake"
require "sinatra/base"
require "sinatra/reloader"
require "i18n"
require_relative "lib/trash_date_parser"
require_relative "lib/downloader"
require_relative "lib/calendar_generator"
I18n.load_path += Dir[File.expand_path("config/locales") + "/*.yml"]
I18n.default_locale = :pl

class Server < Sinatra::Base
  cache_dir = ENV.fetch("CACHE_DIR", "tmp").strip.delete('"\'')
  CACHE_DIR = File.absolute_path?(cache_dir) ? cache_dir : File.join(__dir__, cache_dir)
  CACHE_FILE = File.join(CACHE_DIR, "schedules_cache.json")

  configure :development do
    register Sinatra::Reloader
  end

  helpers do
    def webcal_url
      request.url.sub(/^http(s)?/, "webcal").sub(/\/$/, "") + "/calendar.ics"
    end

    def get_cached_data
      if cache_valid?
        JSON.parse(File.read(CACHE_FILE))
      else
        begin
          fresh_data = Downloader.download_all
          if fresh_data["schedules"].empty?
            raise "Download returned empty schedules — not caching"
          end
          cache_data = fresh_data.merge("cached_at" => DateTime.now.to_s)
          FileUtils.mkdir_p(CACHE_DIR)
          File.write(CACHE_FILE, JSON.generate(cache_data))
          cache_data
        rescue => e
          puts "Error downloading fresh data: #{e.message}"
          if File.exist?(CACHE_FILE)
            JSON.parse(File.read(CACHE_FILE))
          else
            {
              "schedules" => [],
              "scheduleDescription" => [],
              "changeDate" => DateTime.now.to_s,
              "cached_at" => DateTime.now.to_s
            }
          end
        end
      end
    end
  end

  def cache_valid?
    return false unless File.exist?(CACHE_FILE)
    cache_data = JSON.parse(File.read(CACHE_FILE))
    cache_time = DateTime.parse(cache_data["cached_at"])
    (DateTime.now - cache_time) < 30 # less than 30 days old
  end

  get "/" do
    data = get_cached_data
    trash = TrashDateParser.new(data)
    erb :index, layout: :layout, locals: {
      trash: trash,
      cached_at: DateTime.parse(data["cached_at"])
    }
  end

  get "/calendar.ics" do
    data = get_cached_data
    trash = TrashDateParser.new(data)
    calendar_generator = CalendarGenerator.new(trash)

    content_type "text/calendar"
    calendar_generator.generate
  end
end
