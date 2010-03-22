module RenderFarm

  helpers do

    def get_task_stauts(id)
      task = Task.first(:id => id)
      task || throw_bad_request
    end
    
    def set_task_status(task, status)
      throw_bad_request unless options.task_status[task.status].include? status
      task.status = status
      task.modified = Time.now
      throw_bad_request unless task.save
      json({
        :id => task.id,
        :status => status,
        :modified => task.modified
      })
    end

  end

  get '/tasks/:id' do
    local_area!
    task = Task.first(:id => params[:id])
    throw_bad_request unless task
    json task.attributes.merge({:directory => File.join(options.tasks_dir, task.hash)})
  end

  post '/tasks/:id' do
    local_area!
    requires params, :status
    if task = get_task_stauts(params[:id])
      set_task_status(params[:id], params[:status].to_sym)
    end
  end

end
