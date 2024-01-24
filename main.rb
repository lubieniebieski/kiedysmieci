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
I18n.load_path += Dir[File.expand_path("config/locales") + "/*.yml"]
I18n.default_locale = :pl

class Server < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get "/" do
    trash = TrashDateParser.new(File.read("data.json"))
    erb :index, layout: :layout, locals: {trash: trash}
  end
end
