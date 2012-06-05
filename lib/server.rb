class RichardStallmanVisitsForward < Sinatra::Application

  helpers do

    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Restricted Area")
        throw(:halt, [401, "Not authorized\n"])
      end
    end

    def authorized?
      return true unless (ENV["STALLMANUSERNAME"] && ENV["STALLMANPASSWORD"])
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [ENV["STALLMANUSERNAME"], ENV["STALLMANPASSWORD"]]
    end
    
    def db
      if ENV['MONGOHQ_URL']
        conn = Mongo::Connection.from_uri(URI.parse(ENV['MONGOHQ_URL']))
        return conn.db(ENV['MONGOHQ_URL'])
      else
        return Mongo::Connection.new("localhost", "27017")['stallman']
      end 
    end
    
    def collection
      @db ||= db 
      @db['attendees'] 
    end
  end
  
  get '/' do
    haml :index, :locals => {:confirmed => false}
  end
  
  post '/' do
    collection.insert({:email => params[:email]})
    haml :index, :locals => {:confirmed => true}
  end
  
  get '/emails' do
    protected!
    haml :emails, :locals => {:emails => collection.find}
  end
  
end
