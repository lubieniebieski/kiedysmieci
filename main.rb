require 'bundler/setup'
require 'dotenv/load'
require 'http'
require 'json'
require 'pry'
require 'rake'
require 'sinatra/base'
require 'sinatra/reloader'

class Server < Sinatra::Base
  configure :development do
    register Sinatra::Reloader
  end

  get '/' do
    render 'hello world'
  end
end
