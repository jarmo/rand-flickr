# encoding: UTF-8
require "bundler"
Bundler.require

require File.expand_path("flickr-api", __dir__)

class RandFlickr < Sinatra::Base
  configure do
    set :root, File.expand_path("..", __dir__)
    enable :sessions
  end

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader
  end

  get "/" do
    username = params[:user] || "jarm0"
    photo = FlickrApi.new(ENV["FLICKR_API_KEY"], username).random_photo
    session[:photo] = photo
    redirect to("/photo/#{username}/#{photo[:photoset][:id]}/#{photo[:id]}")
  end

  get "/photo/:user/:photoset_id/:photo_id" do
    @photo = session.delete(:photo) || FlickrApi.new(ENV["FLICKR_API_KEY"], params[:user]).photo(params[:photoset_id], params[:photo_id])
    haml :index
  end

  get "/style.css" do
    scss :style
  end

  run! if app_file == $0
end
