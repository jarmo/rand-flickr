require "dotenv"
Dotenv.load
require "sinatra"
require "haml"
require "sassc"
require "json"
require File.expand_path("flickr_api", __dir__)

class RandFlickr < Sinatra::Base
  configure do
    set :root, File.expand_path("..", __dir__)
    enable :sessions
  end

  configure :development do
    require "sinatra/reloader"
    register Sinatra::Reloader

    require "rack-livereload"
    use Rack::LiveReload
  end

  configure :production do
    require "raven"
    use Raven::Rack
    set :protection, :except => :frame_options
    
    Raven.configure do |config|
      config.dsn = ENV["SENTRY_DSN"]
    end
  end

  helpers do
    def random_background_image
      "images/#{File.basename(Dir.glob(File.join(settings.public_folder, "images", "*.jpg")).sample)}"
    end
  end

  get "/" do
    haml :index, escape_html: false
  end

  get "/photo" do
    user = params[:user]
    if user.empty?
      @error = "User not specified"
      return haml :index, escape_html: false
    end

    call env.merge("PATH_INFO" => "/photo/#{user}")
  end

  get "/photo/:user.json" do
    username = params[:user]
    photo = random_photo username 
    photo.merge!(browser_url: browser_url(username, photo))

    content_type :json
    JSON.dump photo
  end

  get "/photo/:user" do
    username = params[:user]
    begin
      session[:photo] = photo = random_photo username
    rescue FlickrApi::Error::UserNotFoundError, FlickrApi::Error::NoPhotosetsError => e
      @error = e.message
      return haml :index, escape_html: false
    end

    redirect to(browser_url(username, photo))
  end

  get "/photo/:user/:photoset_id/:photo_id" do
    @username = params[:user]
    @photo = session.delete(:photo) || FlickrApi.new(ENV["FLICKR_API_KEY"], @username).photo(params[:photoset_id], params[:photo_id])
    haml :photo, escape_html: false
  end

  STYLE = SassC::Engine.new(File.read(File.join(__dir__, "../views/style.scss")), style: :compressed).render
  get "/style.css" do
    content_type "text/css; charset=utf-8"
    STYLE
  end

  private

  def random_photo(username)
    FlickrApi.new(ENV["FLICKR_API_KEY"], username).random_photo
  end

  def browser_url(username, photo)
    "/photo/#{username}/#{photo[:photoset][:id]}/#{photo[:id]}"
  end

  run! if app_file == $0
end
