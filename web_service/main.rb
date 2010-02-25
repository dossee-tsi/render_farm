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

  get '/' do
    tasks = Task.all(
      :conditions => { :status => options.task_status - [:rejected, :completed] },
      :order => 'created desc'
    )
    erb :index, :locals => { :tasks => tasks }
  end

  post '/clients' do
    # register
  end

  get '/clients/:id' do
    # info
  end

  put '/clients/:id' do
    # credits
  end

  post '/tasks' do
    # upload
  end

  get '/tasks/:id' do
    # status, xml, blend, output
  end

  put '/tasks/:id' do
    # accept, reject
  end

end
