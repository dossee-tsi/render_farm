module RenderFarm

  helpers do

    def get_task(hash)
      task = Task.first(:hash => hash)
      task || throw_bad_request
    end
    
    def set_task_status(task, status)
      throw_bad_request unless options.task_status[task.status].include? status
      task.status = status
      task.modified = Time.now
      throw_bad_request unless task.save
      json({
        :hash => task.hash,
        :status => status,
        :modified => task.modified
      })
    end

  end

  get '/tasks/:hash' do
    local_area!
    task = get_task(params[:hash])
    throw_bad_request if task.status == :uploaded
    task.status = :examined if task.status == :unpacked
    json task.attributes.merge({:directory => File.join(options.tasks_dir, task.hash)})
  end

  post '/tasks/:hash' do
    local_area!
    requires params, :status
    if task = get_task(params[:hash])
      set_task_status(task, params[:status].to_sym)
    end
  end

end
