class Email
  @queue = :send_email

  def self.perform(email)
     Pony.mail({
        :to => 'email',
        :from => 'confirmation@forward',
        :subject => 'Thank you for registering',
        :html_body => haml(:email),    
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
  end
end