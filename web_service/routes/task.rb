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
    if task.status == :unpacked
      task.status = :examined
      task.save
    end
    json task.attributes.merge({ :directory => File.join(options.tasks_dir, task.hash) })
  end

  post '/tasks/:hash' do
    local_area!
    requires params, :status
    if task = get_task(params[:hash])
      set_task_status(task, params[:status].to_sym)
    end
  end
  
  get '/pictures/:hash' do
    client_area!
    task = get_task(params[:hash])
    file_name = File.join(options.tasks_dir, task.hash, 'scene.png')
    if file_size = File.size? file_name
      content_type :png
      headers({
        'Content-Disposition' => 'inline; filename="' + task.hash + '.png"',
        'Content-Length' => file_size,
        'Cache-Control' => 'no-store, no-cache, must-revalidate, post-check=0, pre-check=0',
        'Pragma' => 'no-cache'
      })
      File.read(file_name)
    end
  end

end
