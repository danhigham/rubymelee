$:.push File.expand_path("../lib", __FILE__)

require 'sinatra/base'
require 'sequel'
require 'uuidtools'
require 'json'
require 'eventmachine'
require 'faye'
require 'ruby_melee'

class RubyMeleeApp < Sinatra::Base

  PROD_DB_URL = ''

  set :public_folder, 'public'

  def initialize
    init_db
    super
  end

  get '/' do
    redirect '/index.html' 
  end

  get '/new' do
    # create a new melee
    container_handle = warden_client.launch_container

    melee = Melee.create :container_handle => container_handle, :content => "def print_time\n  puts Time.now\nend\n\nprint_time"
    @guid = melee.guid

    redirect "/melee/#{@guid}"
  end

  get '/melee/*' do
    melee = Melee.where(:guid => params[:splat]).first
    halt 404 if melee.nil?

    @guid = melee.guid
    @content = melee.content
    @client_guid = UUIDTools::UUID.random_create.to_s
    
    erb :melee_layout do
      erb :melee
    end
  end

  post '/melee/*' do
    melee = Melee.where(:guid => params[:splat]).first
    halt 404 if melee.nil?

    content_type :json

    @guid = melee.guid
    handle = melee.container_handle
    melee.update :content => request.POST['content']

    output = warden_client.run handle, melee.content

    em_thread = Thread.new {
      EM.run {
        client = Faye::Client.new('http://localhost:8000/melee')
        client.publish("/#{@guid}/update", { 'content' => melee.content, 'output' => output }.to_json )      
        client.disconnect
      }
    }

    halt 200
  end

  :private

  def init_db
    # inspect ruby env
    @db = ENV['RUBY_ENV'] == 'production' ? Sequel.connect(PROD_DB_URL) : Sequel.sqlite
    @db.loggers << Logger.new($stdout)

    Sequel.extension :migration
    Sequel::Migrator.apply(@db, './migrations/')

    require './models'
  end

  def warden_client
    File.file?('/tmp/warden.sock') ? RubyMelee::WardenClient : RubyMelee::FakeWardenClient
  end

end