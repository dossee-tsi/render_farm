module RenderFarm

  require 'json'
  require 'mongo_mapper'
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

  # Authentication

  helpers do

    def local_area!
      throw(:halt, [401, "Sorry. :)\n"]) unless @env['REMOTE_ADDR'] === '127.0.0.1'
    end

    def client_area!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="DOSSEE TSI Render Farm")
        throw(:halt, [401, "Sorry. :)\n"])
      end
    end

    def authorized?
      @auth ||= Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == ['admin', 'admin']
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
    # register
  end

  get '/client' do
    client_area!
    # info
  end

  post '/client' do
    client_area!
    # credits
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
