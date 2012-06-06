class RichardStallmanVisitsForward < Sinatra::Application

  MAX_ATTENDEES = 70
  
  helpers do
    def connection
      if ENV['MONGOHQ_URL']
        uri = URI.parse(ENV['MONGOHQ_URL'])
        conn = Mongo::Connection.from_uri(ENV['MONGOHQ_URL'])
        return conn.db(uri.path.gsub(/^\//, ''))
      else
        return Mongo::Connection.new("localhost", "27017")['stallman']
      end 
    end
    
    def db
      @db ||= connection
      @db
    end
    
    def collection
      return db['attendees'] unless full?
      db['backups']
    end
    
    def full?
      db['attendees'].count >= MAX_ATTENDEES
    end
    
  end
  
  get '/' do
    haml :index, :locals => {:confirmed => false, :full => full?}
  end
  
  post '/' do
    collection.insert({:email => params[:email]})
    Pony.mail({
        :to => params[:email],
        :from => 'Forward <confirmation@forward.co.uk>',
        :subject => 'Thank you for registering',
        :html_body => haml(full? ? :backup : :email),
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
      }) if ENV['SENDGRID_USERNAME']
    haml :index, :locals => {:confirmed => true}
  end
  
  get '/test-backup' do
    haml :index, :locals => {:confirmed => false, :full => true}
  end
  
  get '/test-backup-email' do
    Pony.mail({
        :to => "jon.neale@forward.co.uk",
        :from => 'Forward <confirmation@forward.co.uk>',
        :subject => 'Thank you for registering',
        :html_body => haml(true ? :backup : :email),
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
      }) if ENV['SENDGRID_USERNAME']
    haml :index, :locals => {:confirmed => true}
  end
end
