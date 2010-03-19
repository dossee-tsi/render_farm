module RenderFarm

  helpers do

    def set_task_status(id, status)
      task = Task.first(:id => id)
      throw_bad_request unless task
      throw_bad_request unless ['unpacked', 'examined'].include? task.status.to_s
      throw_bad_request if task.status.to_s == 'unpacked' and status == :accepted
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
    requires params, :status
    status = params[:status].to_sym
    if options.task_status.include? status
      set_task_status(params[:id], status) 
    else
      throw_bad_request
    end
  end

end
