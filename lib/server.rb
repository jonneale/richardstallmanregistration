class RichardStallmanVisitsForward < Sinatra::Application
  
  configure do
    uri = URI.parse(ENV["REDISTOGO_URL"] || "localhost")
    REDIS = Redis.new(:host => uri.host, :port => uri.port, :password => uri.password)
  end
  
  get '/' do
    haml :index, :locals => {:confirmed => false}
  end
  
  post '/' do
    REDIS.sadd("attending", params[:email])
    haml :index, :locals => {:confirmed => true}
  end
  
  use Rack::Auth::Basic, "Restricted Area" do |username, password|
    [username, password] == [ENV["STALLMANUSERNAME"], ENV["STALLMANPASSWORD"]]
  end
  
  get '/emails' do
    haml :emails
  end
  
end
