# encoding: UTF-8
require "bundler"
Bundler.require

require File.expand_path("flickr-api", __dir__)

class RandFlickr < Sinatra::Base
  configure do
    set :root, File.expand_path("..", __dir__)
  end

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
  end

  get "/" do
    @photo = FlickrApi.new(ENV["FLICKR_API_KEY"], params[:user] || "jarm0").random_photo_info
    haml :index
  end

  get "/style.css" do
    scss :style
  end

  run! if app_file == $0
end
