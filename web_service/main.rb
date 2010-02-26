module RenderFarm

  require 'json'
  require 'mongo_mapper'
  require 'digest/sha1'
  require 'client'
  require 'task'

  # Database

  configure do
    MongoMapper.database = 'renderfarm'
    set :task_status, [
      :uploaded,
      :examined,
      :rejected,
      :accepted,
      :sent,
      :deployed,
      :completed
    ]
  end

  # Utilities

  helpers do

    def throw_bad_request
      throw :halt, [400, "We are not amused by your request.\n"]
    end

    def throw_unauthorized
      throw :halt, [401, "We hate you. Go away.\n"]
    end

    def requires(params, *keys)
      keys.each {|key| throw_bad_request unless params.include? key.to_s }
    end

    def one_of(params, *keys)
      keys.each {|key| return key if params.include? key.to_s }
      throw_bad_request
    end

    def local_area!
      throw_unauthorized unless @env['REMOTE_ADDR'] === '127.0.0.1'
    end

    def client_area!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="DOSSEE TSI Render Farm")
        throw_unauthorized
      end
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials &&
        Client.first(:email => @auth.credentials[0], :password => Digest::SHA1.hexdigest(@auth.credentials[1]))
    end

  end

  # Routes

  get '/' do
    local_area!
    tasks = Task.all(
      :conditions => { :status => options.task_status - [:rejected, :completed] },
      :order => 'created desc'
    )
    erb :index, :locals => { :tasks => tasks }
  end

  post '/register' do
    local_area!
    requires params, :email, :password
    client = Client.new({
      :email => params[:email],
      :password => Digest::SHA1.hexdigest(params[:password]),
      :created => Time.new,
      :render_time => 0,
      :tasks => []
    })
    if client.save
      content_type :json, :charset => 'utf-8'
      { :id => client.id, :created => client.created }.to_json
    else
      throw_bad_request
    end
  end

  get '/client' do
    client_area!
    client = Client.first(:email => @auth.credentials[0])
    content_type :json, :charset => 'utf-8'
    {
      :email => client.email,
      :created => client.created,
      :render_time => 0,
      :tasks => []
    }.to_json
  end

  post '/client' do
    local_area!
    requires params, :render_time
    key = one_of params, :id, :email
    client = Client.first(key => params[key])
    updated = false
    if client
      client.render_time = params[:render_time]
      updated = client.save
    end
    if updated
      content_type :json, :charset => 'utf-8'
      {
        :id => client.id,
        :email => client.email,
        :created => client.created,
        :render_time => client.render_time
      }.to_json
    else
      throw_bad_request
    end
  end

  post '/tasks' do
    client_area!
    # upload
  end

  get '/tasks/:id' do
    local_area!
    # status, xml, blend, output
  end

  post '/tasks/:id' do
    local_area!
    # accept, reject
  end

end
