class RichardStallmanVisitsForward < Sinatra::Application

  helpers do
    def db
      if ENV['MONGOHQ_URL']
        uri = URI.parse(ENV['MONGOHQ_URL'])
        conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
        return conn.db(uri.path.gsub(/^\//, ''))
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
    Pony.mail({
        :to => params[:email],
        :from => 'Forward <confirmation@forward.co.uk>',
        :subject => 'Thank you for registering',
        :html_body => haml(:email),
        :bcc => "jon.neale@forward.co.uk",
        :via => :smtp,
        :via_options => {
          :address => 'smtp.sendgrid.net',
          :port => '587',
          :domain => 'heroku.com',
          :user_name => ENV['SENDGRID_USERNAME'],
          :password => ENV['SENDGRID_PASSWORD'],
          :authentication => :plain,
          :enable_starttls_auto => true
        }
      })
    haml :index, :locals => {:confirmed => true}
  end
end
