require 'sinatra'
require 'sinatra/reloader' if development?
require 'slim'
require 'sass'
require './song'
require 'sinatra/flash'
require 'pony'
require 'v8'
require 'coffee-script'

before do
  set_title
end

configure do
  enable :sessions
  set :username, 'frank'
  set :password, 'sinatra'
end

configure :production do 
  DataMapper.setup(:default, ENV['DATABASE_URL'] || "postgres://localhost/[HEROKU_POSTGRESQL_BLACK_URL]")
end

configure :development do 
  DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/development.db")
end

helpers do
  def css(*stylesheets)
    stylesheets.map do |stylesheet|
      "<link href=\"/#{stylesheet}.css\" media=\"screen, projection\" rel=\"stylesheet\" />"
    end.join
  end

  def current?(path='/')
    (request.path==path || request.path==path+'/') ? "current" : nil
  end

  def set_title
    @title ||= "Songs By Sinatra"
  end

  def send_message
    Pony.mail(
      :from => params[:name] + "<" + params[:email] + ">",
      :to => 'adames.larry@gmail.com',
      :subject => params[:name] + " has contact you",
      :body => params[:message],
      :port => '587',
      :via => :smtp,
      :via_options => {
        :address              => 'smtp.gmail.com',
        :port                 => '587',
        :enable_starttls_auto => true,
        :user_name            => 'adames.larry',
        :password             => 'secret',
        :authentication       => :plain,
        :domain               => 'localhost.localdomain'
      })
  end

end


get '/' do 
  slim :home
end

get '/about' do
  @title = "All About This Website" 
  slim :about
end

get '/contact' do 
  slim :contact
end

not_found do 
  slim :not_found
end

get '/login' do 
  slim :login
end

post '/login' do 
  if params[:username] == settings.username && params[:password] == settings.password
    session[:admin] = true
    redirect to('/songs')
  else
    slim :login
  end
end

get '/logout' do
  session.clear
  redirect to('/login')
end

post '/contact' do
  send_message
  flash[:notice] = "Thank you for your message. We'll be in touch soon."
  redirect to('/')
end

get('/styles.css'){scss :styles}
get('/javascripts/application.js'){ coffee :application}