require 'sinatra'
require "sinatra/basic_auth"
require 'data_mapper'
require 'time'
 
enable :sessions
set :session_secret, 'secret'

SITE_TITLE = "Songbook"
SITE_DESCRIPTION = "a simple blogging platform"

DataMapper::setup(:default, "sqlite3://#{Dir.pwd}/songs.db")
 
class Song
  include DataMapper::Resource
  property :id, Serial
  property :title_post, String, :required => true
  property :content, Text, :required => true
  property :created_at, DateTime
  property :updated_at, DateTime
end
 
DataMapper.finalize.auto_upgrade!

helpers do
  include Rack::Utils
  alias_method :h, :escape_html
end

authorize "Admin" do |username, password|
  username == "admin" && password == "admin"
end

get '/' do
    @songs = Song.all :order => :id.desc
    @title = 'All Posts'
    erb :start
end

protect "Admin" do
	get '/panel' do
		  @songs = Song.all :order => :id.desc
		  @title = 'All Posts'
		  erb :home
	end

	post '/panel' do
		  s = Song.new
		  s.content = params[:content]
		  s.title_post = params[:title_post]
		  s.created_at = Time.now
		  s.updated_at = Time.now
		  s.save
		  redirect '/panel'
	end

	get '/panel/:id' do
		  @song = Song.get params[:id]
		  @title = "Edit note ##{params[:id]}"
		  if @song
		      erb :edit
		  else
		      redirect '/panel'
		  end
	end

	put '/panel/:id' do
		  s = Song.get params[:id]
		  s.content = params[:content]
		  s.title_post = params[:title_post]
		  s.updated_at = Time.now
		  s.save
		  redirect '/panel'    
	end

	get '/panel/:id/delete' do
		  @song = Song.get params[:id]
		  @title = "Confirm deletion of post ##{params[:id]}"
		  if @song
		     erb :delete
		  end
	end

	delete '/panel/:id' do
		  s = Song.get params[:id]
		  s.destroy
		  redirect '/panel'
	end
end
