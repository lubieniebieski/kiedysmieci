require "bundler/setup"
require "dotenv/load"
require "http"
require "json"
require "pry"
require "rake"
require "sinatra/base"
require "sinatra/reloader"
require "i18n"
require_relative "lib/trash_date_parser"
require_relative "lib/downloader"
I18n.load_path += Dir[File.expand_path("config/locales") + "/*.yml"]
I18n.default_locale = :pl

class Server < Sinatra::Base
  CACHE_FILE = File.join(__dir__, "tmp", "schedules_cache.json")

  configure :development do
    register Sinatra::Reloader
    FileUtils.mkdir_p(File.dirname(CACHE_FILE))
  end

  def cache_valid?
    return false unless File.exist?(CACHE_FILE)
    cache_data = JSON.parse(File.read(CACHE_FILE))
    cache_time = DateTime.parse(cache_data["cached_at"])
    (DateTime.now - cache_time) < 30 # less than 30 days old
  end

  get "/" do
    data = if cache_valid?
      JSON.parse(File.read(CACHE_FILE))
    else
      fresh_data = Downloader.download_all
      cache_data = fresh_data.merge("cached_at" => DateTime.now.to_s)
      File.write(CACHE_FILE, JSON.generate(cache_data))
      cache_data
    end

    trash = TrashDateParser.new(data)
    erb :index, layout: :layout, locals: {trash: trash}
  end
end
