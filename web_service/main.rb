module RenderFarm

  require 'json'
  require 'mongo_mapper'
  require 'digest/sha1'
  require 'fileutils'
  require 'zip/zip'
  require 'client'
  require 'task'

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

    def json(map)
      content_type :json, :charset => 'utf-8'
      map.to_json
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

  get '/newtask' do
    #temp
    task = Task.new
    task.status = :uploaded
    task.client_id = Client.first(:id => '4b87f873b1e38c1885000001').id
    task.modified = Time.now
    task.created = task.modified
    task.hash = ""
    40.times do
      task.hash += rand(9).to_s
    end
    task.render_time = 100
    task.render_start = nil
  end

  load 'routes/register.rb'
  load 'routes/client.rb'
  load 'routes/tasks.rb'

end
