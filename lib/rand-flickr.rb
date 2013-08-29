# encoding: UTF-8
require "bundler"
Bundler.require

class RandFlickr < Sinatra::Base
  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
  end

  get "/" do
    haml :index
  end

  get "/style.css" do
    scss :style
  end

  run! if app_file == $0
end
