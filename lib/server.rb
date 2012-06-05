class RichardStallmanVisitsForward < Sinatra::Application

  helpers do

    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV["STALLMANUSERNAME"], ENV["STALLMANPASSWORD"]]
    end

  end
  
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
  
  get '/emails' do
    protected!
    haml :emails
  end
  
end
