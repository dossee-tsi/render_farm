module RenderFarm

  helpers do

    def set_task_status(id, status)
      task = Task.first(:id => id)
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
    # status, xml, blend, output
  end

  post '/tasks/:id' do
    local_area!
    requires params, :action
    case params[:action]
    when 'accept' then set_task_status(params[:id], :accept)
    when 'reject' then set_task_status(params[:id], :reject)
    else throw_bad_request
    end
  end

end
