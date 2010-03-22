module RenderFarm

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
    throw_bad_request unless client.save
    json({
      :id => client.id,
      :created => client.created
    })
  end
  
  get '/cluster' do
    local_area!
    json({ :ips => options.cluster_ips })
  end
  
  get '/statuses' do
    status_count = options.task_status.keys.inject({}) do |hash, key| 
      hash[key] = 0
      hash
    end
    tasks = Task.all
    tasks.each do |task|
      status_count[task.status] += 1 if status_count.include? task.status
    end
    json(status_count)
  end

end
