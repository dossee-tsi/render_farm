module RenderFarm

  helpers do

    def set_task_status(id, status)
      task = Task.first(:id => id)
      throw_bad_request unless task
      throw_bad_request if task.status == status
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
    json task.attributes.merge({:directory => File.join(options.lx_dir, task.hash)})
  end

  post '/tasks/:id' do
    local_area!
    requires params, :action
    case params[:action]
    when 'accept' then set_task_status(params[:id], :accepted)
    when 'reject' then set_task_status(params[:id], :rejected)
    else throw_bad_request
    end
  end

end
